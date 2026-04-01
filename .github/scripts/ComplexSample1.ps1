# =========================
# ADSI + Core helpers
# =========================
function Get-DefaultNamingContext {
    param([string]$Server)
    $root = if ($Server) { [ADSI]"LDAP://$Server/RootDSE" } else { [ADSI]"LDAP://RootDSE" }
    $root.defaultNamingContext
}

function Resolve-DN {
    param(
        [Parameter(Mandatory)] [string] $Identity,
        [ValidateSet('user', 'group', 'computer')] [string] $ObjectClass,
        [string] $Server
    )
    if ($Identity -match '^[a-zA-Z]+=.+,.+=.+') { return $Identity } # already DN

    $base = Get-DefaultNamingContext -Server $Server
    $de = New-Object System.DirectoryServices.DirectoryEntry(("LDAP://{0}/{1}" -f ($Server ?? ''), $base).Trim('/'))
    $ds = New-Object System.DirectoryServices.DirectorySearcher($de)
    $ds.PropertiesToLoad.Add('distinguishedName') | Out-Null
    $ds.Filter = "(&(objectClass=$ObjectClass)(|(sAMAccountName=$Identity)(cn=$Identity)))"
    $r = $ds.FindOne()
    if (-not $r) { throw "Resolve-DN: $ObjectClass '$Identity' not found." }
    $r.Properties['distinguishedname'][0]
}

function Get-ADsPath { param([string]$DN, [string]$Server) if ($Server) { "LDAP://$Server/$DN" } else { "LDAP://$DN" } }

# =========================
# Enable / Disable user
# =========================
function Enable-ADUserADSI {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string]$User, [string]$Server)
    $dn = Resolve-DN -Identity $User -ObjectClass user -Server $Server
    $de = [ADSI](Get-ADsPath -DN $dn -Server $Server)
    $uac = [int]$de.Properties['userAccountControl'].Value
    $new = ($uac -band (-bnot 2))            # clear ACCOUNTDISABLE (0x2)
    if ($PSCmdlet.ShouldProcess($dn, "Enable")) { $de.Properties['userAccountControl'].Value = $new; $de.CommitChanges() }
}
function Disable-ADUserADSI {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string]$User, [string]$Server)
    $dn = Resolve-DN -Identity $User -ObjectClass user -Server $Server
    $de = [ADSI](Get-ADsPath -DN $dn -Server $Server)
    $uac = [int]$de.Properties['userAccountControl'].Value
    $new = ($uac -bor 2)                     # set ACCOUNTDISABLE (0x2)
    if ($PSCmdlet.ShouldProcess($dn, "Disable")) { $de.Properties['userAccountControl'].Value = $new; $de.CommitChanges() }
}

# =========================
# Move user between OUs
# =========================
function Move-ADUserADSI {
    <#
      .EXAMPLE Move-ADUserADSI -User alice -TargetOU "OU=Finance,DC=contoso,DC=local"
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$User,
        [Parameter(Mandatory)][string]$TargetOU,
        [string]$Server
    )
    $userDN = Resolve-DN -Identity $User -ObjectClass user -Server $Server
    $userDE = [ADSI](Get-ADsPath -DN $userDN  -Server $Server)
    $tgtDE = [ADSI](Get-ADsPath -DN $TargetOU -Server $Server)
    if ($PSCmdlet.ShouldProcess($userDN, "MoveTo $TargetOU")) {
        $userDE.MoveTo($tgtDE) | Out-Null
        $tgtDE.CommitChanges()
    }
}

# =========================
# Edit user attributes (Add/Replace/Remove)
# =========================
function Set-ADUserAttributesADSI {
    <#
      .EXAMPLE Set-ADUserAttributesADSI -User alice -Replace @{title='Analyst';telephoneNumber='555-0100'}
      .EXAMPLE Set-ADUserAttributesADSI -User alice -Add @{proxyAddresses='smtp:alias@contoso.local'}
      .EXAMPLE Set-ADUserAttributesADSI -User alice -Remove @('extensionAttribute1','pager')
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$User,
        [hashtable]$Add,
        [hashtable]$Replace,
        [string[]]$Remove,
        [string]$Server
    )
    if (-not ($Add -or $Replace -or $Remove)) { throw "Specify -Add, -Replace, or -Remove." }
    $dn = Resolve-DN -Identity $User -ObjectClass user -Server $Server
    $de = [ADSI](Get-ADsPath -DN $dn -Server $Server)

    if ($PSCmdlet.ShouldProcess($dn, "Modify attributes")) {
        if ($Add) {
            foreach ($k in $Add.Keys) {
                $vals = @($Add[$k]); foreach ($v in $vals) { [void]$de.Properties[$k].Add($v) }
            }
        }
        if ($Replace) {
            foreach ($k in $Replace.Keys) {
                $de.Properties[$k].Clear()
                $vals = @($Replace[$k]); foreach ($v in $vals) { [void]$de.Properties[$k].Add($v) }
            }
        }
        if ($Remove) {
            foreach ($k in $Remove) { $de.Properties[$k].Clear() }
        }
        $de.CommitChanges()
    }
}

# =========================
# Reset password / Unlock account
# =========================
function Reset-ADUserPasswordWinNT {
    <#
      Uses WinNT provider (works on domain-joined admin box).
      For LDAP unicodePwd over LDAPS, use a DC with LDAPS and service creds.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$User,        # sAMAccountName
        [Parameter(Mandatory)][string]$NewPassword,
        [string]$Domain = $env:USERDOMAIN
    )
    $path = "WinNT://$Domain/$User,user"
    $u = [ADSI]$path
    if ($PSCmdlet.ShouldProcess("$Domain\$User", "SetPassword")) {
        $u.SetPassword($NewPassword)
        $u.SetInfo()
    }
}

function Unlock-ADUserADSI {
    [CmdletBinding(SupportsShouldProcess)]
    param([Parameter(Mandatory)][string]$User, [string]$Server)
    $dn = Resolve-DN -Identity $User -ObjectClass user -Server $Server
    $de = [ADSI](Get-ADsPath -DN $dn -Server $Server)
    if ($PSCmdlet.ShouldProcess($dn, "Unlock (lockoutTime=0)")) {
        $de.Properties['lockoutTime'].Value = 0
        $de.CommitChanges()
    }
}

# =========================
# Reset machine account (secure channel repair)
# =========================
function Reset-MachineAccount {
    <#
      .EXAMPLE Reset-MachineAccount -ComputerName WS-01
      .EXAMPLE Reset-MachineAccount -ComputerName SVR-01 -Credential (Get-Credential) -Remote
      If -Remote is not used, acts locally.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ComputerName,
        [switch]$Remote,
        [System.Management.Automation.PSCredential]$Credential
    )
    if ($Remote) {
        $sess = New-PSSession -ComputerName $ComputerName -Credential $Credential
        try {
            Invoke-Command -Session $sess -ScriptBlock {
                try {
                    if (-not (Test-ComputerSecureChannel)) { Test-ComputerSecureChannel -Repair -Credential $using:Credential | Out-Null }
                    else { Test-ComputerSecureChannel -Repair -Credential $using:Credential | Out-Null }
                    'OK'
                }
                catch {
                    # Fallback to nltest
                    & nltest.exe "/SC_RESET:%USERDOMAIN%" | Out-String
                }
            }
        }
        finally { if ($sess) { Remove-PSSession $sess } }
    }
    else {
        try {
            if (-not (Test-ComputerSecureChannel)) { Test-ComputerSecureChannel -Repair | Out-Null }
            else { Test-ComputerSecureChannel -Repair | Out-Null }
            'OK'
        }
        catch {
            & nltest.exe "/SC_RESET:%USERDOMAIN%" | Out-String
        }
    }
}

# =========================
# Run Entra Connect / Cloud Sync delta
# =========================
function Start-DirectoryDeltaSync {
    <#
      Tries (in order):
      - Azure AD Connect (ADSync module): Start-ADSyncSyncCycle -PolicyType Delta
      - DirectorySyncClientCmd.exe Delta (legacy)
      - Cloud Sync (Microsoft Entra Connect Cloud Sync) agent REST trigger not exposed; advise portal/job cadence.
    #>
    [CmdletBinding()]
    param()
    $ok = $false
    try {
        Import-Module ADSync -ErrorAction Stop
        Start-ADSyncSyncCycle -PolicyType Delta
        Write-Verbose "Started ADSync delta via Start-ADSyncSyncCycle."
        $ok = $true
    }
    catch {}
    if (-not $ok) {
        $exe = 'C:\Program Files\Microsoft Azure AD Sync\Bin\DirectorySyncClientCmd.exe'
        if (Test-Path $exe) {
            & $exe delta | Out-Null
            Write-Verbose "Started ADSync delta via DirectorySyncClientCmd.exe."
            $ok = $true
        }
    }
    if (-not $ok) {
        Write-Warning "Could not start a delta sync via ADSync. If using **Cloud Sync**, jobs are agent-driven; trigger from Entra admin center or shorten job interval."
    }
}

# =========================
# Replicate all DCs (forest-wide)
# =========================
function Invoke-ReplicateAllDCs {
    <#
      Forces inbound replication on every DC in every domain in the forest.
      Uses repadmin /syncall /AdeP <dc>.
    #>
    [CmdletBinding()]
    param()
    $forest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
    $domains = $forest.Domains
    $results = @()
    foreach ($d in $domains) {
        foreach ($dc in $d.DomainControllers) {
            $name = $dc.Name
            $p = Start-Process -FilePath "repadmin.exe" -ArgumentList "/syncall", "/AdeP", $name -Wait -PassThru -NoNewWindow
            $results += [pscustomobject]@{ Domain = $d.Name; DC = $name; ExitCode = $p.ExitCode }
        }
    }
    $results
}

# =========================
# Quality-of-life examples
# =========================
<#
# Enable / Disable
Enable-ADUserADSI -User 'alice' -Verbose
Disable-ADUserADSI -User 'alice' -Verbose

# Move
Move-ADUserADSI -User 'alice' -TargetOU 'OU=Finance,DC=contoso,DC=local' -Verbose

# Attributes
Set-ADUserAttributesADSI -User 'alice' -Replace @{title='Senior Analyst';telephoneNumber='555-1001'} -Verbose
Set-ADUserAttributesADSI -User 'alice' -Add @{proxyAddresses=@('SMTP:alice@contoso.com','smtp:a.smith@contoso.local')} -Verbose
Set-ADUserAttributesADSI -User 'alice' -Remove @('pager','extensionAttribute1') -Verbose

# Password + Unlock
Reset-ADUserPasswordWinNT -User 'alice' -NewPassword 'S0meStr0ngP@ss!'
Unlock-ADUserADSI -User 'alice' -Verbose

# Machine account
Reset-MachineAccount -ComputerName 'SVR-FILE01'
Reset-MachineAccount -ComputerName 'SVR-FILE01' -Remote -Credential (Get-Credential)

# Delta sync
Start-DirectoryDeltaSync -Verbose

# Replication
Invoke-ReplicateAllDCs | Format-Table -Auto
#>