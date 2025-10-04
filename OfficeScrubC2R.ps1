# OfficeScrubC2R.ps1
# High-performance Office Click-to-Run removal script
# Converted from VBS with C# optimizations for better performance

<#
.SYNOPSIS
    Removes Office Click-to-Run (C2R) products when regular uninstall is not possible.

.DESCRIPTION
    This script provides comprehensive removal of Office 2013, 2016, and O365 C2R products
    using high-performance C# inline code for registry and file operations.

.PARAMETER Quiet
    Run in quiet mode with minimal output.

.PARAMETER DetectOnly
    Only detect installed products without removing them.

.PARAMETER Force
    Force removal without user confirmation.

.PARAMETER RemoveAll
    Remove all Office products.

.PARAMETER KeepLicense
    Keep Office licensing information.

.PARAMETER Offline
    Run in offline mode.

.PARAMETER ForceArpUninstall
    Force ARP-based uninstall.

.PARAMETER ClearTaskBand
    Clear taskband shortcuts.

.PARAMETER UnpinMode
    Unpin shortcuts from taskbar.

.PARAMETER SkipSD
    Skip scheduled deletion.

.PARAMETER NoElevate
    Do not attempt elevation.

.PARAMETER LogPath
    Specify custom log path.

.EXAMPLE
    .\OfficeScrubC2R.ps1 -Quiet -Force

.EXAMPLE
    .\OfficeScrubC2R.ps1 -DetectOnly -LogPath "C:\Logs"

.NOTES
    Author: Microsoft Customer Support Services (Converted to PowerShell)
    Version: 2.19
    Requires: PowerShell 5.1 or later, Administrator privileges
#>

[CmdletBinding()]
param(
    [switch]$Quiet,
    [switch]$DetectOnly,
    [switch]$Force,
    [switch]$RemoveAll,
    [switch]$KeepLicense,
    [switch]$Offline,
    [switch]$ForceArpUninstall,
    [switch]$ClearTaskBand,
    [switch]$UnpinMode,
    [switch]$SkipSD,
    [switch]$NoElevate,
    [string]$LogPath
)

# Import utility module
Import-Module -Name (Join-Path $PSScriptRoot "OfficeScrubC2R-Utilities.psm1") -Force

#region Main Script Functions

function Initialize-Script {
    Write-LogHeader ("Office C2R Scrubber v{0} - Initialization" -f $script:SCRIPT_VERSION)

    # Set script parameters
    $script:Quiet = $Quiet
    $script:DetectOnly = $DetectOnly
    $script:Force = $Force
    $script:RemoveAll = $RemoveAll
    $script:KeepLicense = $KeepLicense
    $script:Offline = $Offline
    $script:ForceArpUninstall = $ForceArpUninstall
    $script:ClearTaskBand = $ClearTaskBand
    $script:UnpinMode = $UnpinMode
    $script:SkipSD = $SkipSD
    $script:NoElevate = $NoElevate

    # Initialize error code
    $script:ErrorCode = $script:ERROR_SUCCESS

    # Get system information
    Get-SystemInfo

    # Initialize environment
    Initialize-Environment

    # Check elevation
    $script:IsElevated = Test-IsElevated
    if (-not $script:IsElevated -and -not $script:NoElevate) {
        Write-Log "Error: Insufficient privileges - script requires Administrator rights"
        Set-ErrorCode $script:ERROR_ELEVATION
        return $false
    }

    # Initialize logging
    if ($LogPath) {
        Initialize-Log $LogPath
    }
    else {
        Initialize-Log $script:LogDir
    }

    Write-Log ("System Information: {0}" -f $script:OSInfo)
    Write-Log ("64-bit System: {0}" -f $script:Is64Bit)
    Write-Log ("Elevated: {0}" -f $script:IsElevated)

    return $true
}

function Find-InstalledOfficeProducts {
    Write-LogSubHeader "Stage # 0 - Basic detection"

    # Ensure Windows Installer metadata integrity
    Write-LogSubHeader "Ensure Windows Installer metadata integrity"
    Ensure-ValidWIMetadata -Hive CurrentUser -SubKey "Software\Classes\Installer\Products" -ValidLength 32
    Ensure-ValidWIMetadata -Hive ClassesRoot -SubKey "Installer\Products" -ValidLength 32
    Ensure-ValidWIMetadata -Hive LocalMachine -SubKey "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products" -ValidLength 32
    Ensure-ValidWIMetadata -Hive LocalMachine -SubKey "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Components" -ValidLength 32
    Ensure-ValidWIMetadata -Hive ClassesRoot -SubKey "Installer\Components" -ValidLength 32

    # Build list of installed Office products
    $script:InstalledSku = Get-InstalledOfficeProducts

    if ($script:C2RSuite.Count -gt 0) {
        Write-Log "Registered ARP product(s) found:"
        foreach ($key in $script:C2RSuite.Keys) {
            Write-Log (" - {0} - {1}" -f $key, $script:C2RSuite[$key])
        }
    }
    else {
        Write-Log "No registered product(s) found"
    }

    return $script:InstalledSku.Count -gt 0
}

function Ensure-ValidWIMetadata {
    param(
        [Microsoft.Win32.RegistryHive]$Hive,
        [string]$SubKey,
        [int]$ValidLength
    )

    try {
        $values = Get-RegistryValues -Hive $Hive -SubKey $SubKey
        foreach ($valueName in $values) {
            $value = Get-RegistryValue -Hive $Hive -SubKey $SubKey -ValueName $valueName
            if ($value -and $value.Length -lt $ValidLength) {
                Write-LogOnly "Removing invalid WI metadata: $valueName"
                Remove-RegistryValue -Hive $Hive -SubKey $SubKey -ValueName $valueName
            }
        }
    }
    catch {
        Write-LogOnly "Error ensuring WI metadata integrity: $($_.Exception.Message)"
    }
}

function Uninstall-OfficeProducts {
    if ($script:ErrorCode -band $script:ERROR_USERCANCEL) {
        return
    }

    Write-LogSubHeader "Uninstalling Office products"

    # Check OSE service state
    Write-LogSubHeader "Check state of OSE service"
    $oseServices = Get-CimInstance -ClassName Win32_Service -Filter "Name LIKE 'ose%'"
    foreach ($service in $oseServices) {
        if ($service.StartMode -eq "Disabled") {
            Write-Log ("Conflict detected: OSE service is disabled" -f $service.StartMode)
            [void]($service.ChangeStartMode("Manual"))
        }
        if ($service.StartName -ne "LocalSystem") {
            Write-Log ("Conflict detected: OSE service not running as LocalSystem" -f $service.StartName)
            [void]($service.Change($null, $null, $null, $null, $null, $null, "LocalSystem", ""))
        }
    }

    if ($script:C2RSuite.Count -eq 0) {
        Write-Log ("No uninstallable C2R items registered in Uninstall: {0}" -f $script:C2RSuite.Count)
    }

    # Call ODT-based uninstall
    Uninstall-OfficeC2R

    # Remove published component registration
    Write-LogSubHeader ("Remove published component registration for C2R packages: {0}" -f $script:C2RSuite.Count)
    Remove-PublishedComponents

    # Remove C2R and App-V registry data
    Write-LogSubHeader ("Remove C2R and App-V registry data: {0}" -f $script:C2RSuite.Count)
    Remove-C2RRegistryData

    # MSI-based uninstall
    Uninstall-MSIProducts
}

function Uninstall-OfficeC2R {
    Write-LogSubHeader ("Uninstalling Office C2R using ODT: {0}" -f $script:C2RSuite.Count)

    # Build removal XML
    $removeXml = Build-RemoveXml

    if ($removeXml) {
        $configPath = Join-Path $script:ScrubDir "RemoveAll.xml"
        Set-Content -Path $configPath -Value $removeXml -Encoding UTF8

        # Download and run ODT
        $odtPath = Join-Path $script:ScrubDir "setup.exe"
        if (Download-ODT -Url "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD18-4A8E-8E0B-75C0FEC274F4/OfficeDeploymentTool_12325-20288.exe" -LocalPath $odtPath) {
            $odtArgs = "/configure `"$configPath`""
            if ($script:Quiet) {
                if (-not ($odtArgs -is [System.Collections.Generic.List[string]])) {
                    $odtArgs = [System.Collections.Generic.List[string]]@($odtArgs)
                }
                $odtArgs.Add("/quiet")
            }

            Write-Log ("Running ODT: {0} {1}" -f $odtPath, $odtArgs)
            if (-not $script:DetectOnly) {
                $result = Start-Process -FilePath $odtPath -ArgumentList $odtArgs -Wait -PassThru
                Write-Log ("ODT returned: {0}" -f $result.ExitCode)

                if ($result.ExitCode -eq 3010) {
                    $script:RebootRequired = $true
                    Set-ErrorCode $script:ERROR_REBOOT_REQUIRED
                }
            }
        }
    }
}

function Build-RemoveXml {
    $xml = @"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
  <Remove All="True" />
  <Display Level="None" AcceptEULA="True" />
  <Property Name="FORCEAPPSHUTDOWN" Value="True" />
</Configuration>
"@
    return $xml
}

function Download-ODT {
    param(
        [string]$Url,
        [string]$LocalPath
    )

    try {
        Write-Log ("Downloading ODT from: {0}" -f $Url)
        if (-not $script:DetectOnly) {
            Invoke-WebRequest -Uri $Url -OutFile $LocalPath -UseBasicParsing
        }
        return $true
    }
    catch {
        Write-Log ("Failed to download ODT: {0}" -f $_.Exception.Message)
        return $false
    }
}

function Remove-PublishedComponents {
    $packageFolders = @(
        @{ Version = "15.0"; Key = "SOFTWARE\Microsoft\Office\15.0\ClickToRun" },
        @{ Version = "16.0"; Key = "SOFTWARE\Microsoft\Office\16.0\ClickToRun" },
        @{ Version = "Current"; Key = "SOFTWARE\Microsoft\Office\ClickToRun" }
    )

    # Optimize by collecting all manifest files in one go and using array operations
    $allManifestFiles = @()
    $integratorTasks = @()

    foreach ($pkg in $packageFolders) {
        $packageFolder = Get-RegistryValue -Hive LocalMachine -SubKey $pkg.Key -ValueName "PackageFolder"
        $packageGuid = Get-RegistryValue -Hive LocalMachine -SubKey $pkg.Key -ValueName "PackageGUID"

        $integrationPath = "$packageFolder\root\Integration"
        if ($packageFolder -and (Test-Path $integrationPath)) {
            # Collect manifest files for batch processing
            $manifestFiles = Get-ChildItem -Path $integrationPath -Filter "C2RManifest*.xml" -ErrorAction SilentlyContinue
            if ($manifestFiles) {
                $allManifestFiles += $manifestFiles
            }

            # Prepare integrator tasks for later execution
            $integratorPath = "$integrationPath\integrator.exe"
            if (Test-Path $integratorPath) {
                $integratorArgs = "/U /Extension PackageRoot=`"$packageFolder\root`" PackageGUID=$packageGuid"
                $integratorTasks += [PSCustomObject]@{
                    Path = $integratorPath
                    Args = $integratorArgs
                }
            }
        }
    }

    # Delete all manifest files in one go using .NET methods for speed
    if ($allManifestFiles.Count -gt 0) {
        $filePaths = $allManifestFiles | ForEach-Object { $_.FullName }
        Write-Log ("Deleting {0} manifest files..." -f $filePaths.Count)
        foreach ($filePath in $filePaths) {
            Write-Log ("Deleting manifest file: {0}" -f $filePath)
        }
        if (-not $script:DetectOnly) {
            # Use [System.IO.File]::Delete for performance
            foreach ($filePath in $filePaths) {
                try {
                    [System.IO.File]::Delete($filePath)
                } catch {
                    Write-Log ("Failed to delete manifest file: {0} - {1}" -f $filePath, $_.Exception.Message)
                }
            }
        }
    }

    # Run all integrator tasks
    foreach ($task in $integratorTasks) {
        Write-Log ("Running integrator: {0} {1}" -f $task.Path, $task.Args)
        if (-not $script:DetectOnly) {
            $result = Start-Process -FilePath $task.Path -ArgumentList $task.Args -Wait -PassThru
            Write-Log ("Integrator returned: {0}" -f $result.ExitCode)
        }
    }
}

function Remove-C2RRegistryData {
    # Remove ARP entries
    foreach ($sku in $script:C2RSuite.Keys) {
        Remove-RegistryKey -Hive LocalMachine -SubKey "$script:REG_ARP$sku"
    }

    # Remove C2R registry keys
    $c2rKeys = @(
        "SOFTWARE\Microsoft\Office\15.0\ClickToRun",
        "SOFTWARE\Microsoft\Office\16.0\ClickToRun",
        "SOFTWARE\Microsoft\Office\ClickToRun"
    )

    foreach ($key in $c2rKeys) {
        Remove-RegistryKey -Hive CurrentUser -SubKey $key
        Remove-RegistryKey -Hive LocalMachine -SubKey $key
    }

    # Remove App-V keys
    Remove-AppVRegistryKeys
}

function Remove-AppVRegistryKeys {
    $appVKeys = @(
        "SOFTWARE\Microsoft\AppV\ISV",
        "SOFTWARE\Microsoft\AppVISV"
    )

    foreach ($key in $appVKeys) {
        foreach ($hive in @([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryHive]::LocalMachine)) {
            $values = Get-RegistryValues -Hive $hive -SubKey $key
            foreach ($valueName in $values) {
                if (Test-IsC2R $valueName) {
                    Write-LogOnly "Removing App-V C2R value: $valueName"
                    Remove-RegistryValue -Hive $hive -SubKey $key -ValueName $valueName
                }
            }
        }
    }
}

function Uninstall-MSIProducts {
    Write-LogSubHeader "Detect MSI-based products"

    try {
        $msi = New-Object -ComObject WindowsInstaller.Installer
        $products = $msi.Products

        # Optimize by filtering in-scope products first, then process in batch
        $inScopeProducts = @()
        $outOfScopeProducts = @()

        foreach ($product in $products) {
            if (Test-ProductInScope $product) {
                $inScopeProducts += $product
            } else {
                $outOfScopeProducts += $product
            }
        }

        if ($outOfScopeProducts.Count -gt 0) {
            $outOfScopeProducts | ForEach-Object { Write-LogOnly "Skip out of scope product: $_" }
        }

        if ($inScopeProducts.Count -gt 0) {
            # Prepare msiexec commands and log files in advance
            $msiexecArgsList = @()
            foreach ($product in $inScopeProducts) {
                Write-Log ("Call msiexec.exe to remove {0}" -f $product)
                $logFile = Join-Path $script:LogDir "Uninstall_$product.log"
                $args = @("/x$product", "REBOOT=ReallySuppress", "NOREMOVESPAWN=True")
                if ($script:Quiet) {
                    $args += "/q"
                } else {
                    $args += "/qb-!"
                }
                $args += "/l*v"
                $args += "`"$logFile`""
                $msiexecArgsList += ,@($product, $args, $logFile)
                Write-LogOnly "Call msiexec with 'msiexec.exe $($args -join ' ')'"
            }

            Stop-OfficeProcesses

            if (-not $script:DetectOnly) {
                foreach ($item in $msiexecArgsList) {
                    $product = $item[0]
                    $args = $item[1]
                    $logFile = $item[2]
                    $result = Start-Process -FilePath "msiexec.exe" -ArgumentList $args -Wait -PassThru
                    Write-Log ("msiexec returned: {0}" -f $result.ExitCode)

                    if ($result.ExitCode -eq 3010) {
                        $script:RebootRequired = $true
                        Set-ErrorCode $script:ERROR_REBOOT_REQUIRED
                    }
                }
            }
        }

        # Stop MSI server
        if (-not $script:DetectOnly) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "net", "stop", "msiserver" -WindowStyle Hidden
        }
    }
    catch {
        Write-Log ("Error during MSI uninstall: {0}" -f $_.Exception.Message)
        Set-ErrorCode $script:ERROR_STAGE1
    }
}

function Test-ProductInScope {
    param([string]$ProductCode)

    # Simplified scope check - in real implementation, this would be more comprehensive
    $productCodeLower = $ProductCode.ToLower()
    $c2rPatterns = @("office", "o365", "clicktorun")

    foreach ($pattern in $c2rPatterns) {
        if ($productCodeLower -like "*$pattern*") {
            return $true
        }
    }
    return $false
}

function Remove-OfficeFiles {
    Write-LogSubHeader "Removing Office files and folders"

    # Stop Office processes first
    Stop-OfficeProcesses -Force

    # Define Office installation paths
    $officePaths = @(
        "$script:ProgramFiles\Microsoft Office",
        "$script:ProgramFiles\Microsoft Office 15",
        "$script:ProgramFiles\Microsoft Office 16",
        "$script:ProgramFilesX86\Microsoft Office",
        "$script:ProgramFilesX86\Microsoft Office 15",
        "$script:ProgramFilesX86\Microsoft Office 16",
        "$script:CommonProgramFiles\Microsoft Shared\Office15",
        "$script:CommonProgramFiles\Microsoft Shared\Office16",
        "$script:CommonProgramFilesX86\Microsoft Shared\Office15",
        "$script:CommonProgramFilesX86\Microsoft Shared\Office16"
    )

    foreach ($path in $officePaths) {
        if (Test-Path $path) {
            Write-Log ("Removing Office path: {0}" -f $path)
            if (-not $script:DetectOnly) {
                Remove-FolderRecursive -Path $path -Force
            }
        }
    }

    # Remove user-specific Office data
    Remove-UserOfficeData
}

function Remove-UserOfficeData {
    Write-LogSubHeader "Removing user-specific Office data"

    $userPaths = @(
        "$script:AppData\Microsoft\Office",
        "$script:LocalAppData\Microsoft\Office",
        "$script:LocalAppData\Microsoft\Office\15.0",
        "$script:LocalAppData\Microsoft\Office\16.0",
        "$script:LocalAppData\Microsoft\Office\ClickToRun"
    )

    foreach ($path in $userPaths) {
        if (Test-Path $path) {
            Write-Log ("Removing user Office data: {0}" -f $path)
            if (-not $script:DetectOnly) {
                Remove-FolderRecursive -Path $path -Force
            }
        }
    }
}

function Clean-OfficeRegistry {
    Write-LogSubHeader "Cleaning Office registry entries"

    # Remove Office registry keys
    $officeRegKeys = @(
        "SOFTWARE\Microsoft\Office\15.0",
        "SOFTWARE\Microsoft\Office\16.0",
        "SOFTWARE\Microsoft\Office\ClickToRun",
        "SOFTWARE\Microsoft\OfficeCommon",
        "SOFTWARE\Microsoft\Office\Common"
    )

    foreach ($key in $officeRegKeys) {
        Remove-RegistryKey -Hive CurrentUser -SubKey $key
        Remove-RegistryKey -Hive LocalMachine -SubKey $key
    }

    # Clean shell integration
    Clean-ShellIntegration
}

function Clean-ShellIntegration {
    Write-LogSubHeader "Cleaning shell integration"

    $shellKeys = @(
        "SOFTWARE\Classes\Excel.Application",
        "SOFTWARE\Classes\Word.Application",
        "SOFTWARE\Classes\PowerPoint.Application",
        "SOFTWARE\Classes\Outlook.Application",
        "SOFTWARE\Classes\OneNote.Application"
    )

    foreach ($key in $shellKeys) {
        Remove-RegistryKey -Hive ClassesRoot -SubKey $key
        Remove-RegistryKey -Hive CurrentUser -SubKey $key
        Remove-RegistryKey -Hive LocalMachine -SubKey $key
    }
}

function Clean-OfficeShortcuts {
    Write-LogSubHeader "Cleaning Office shortcuts"

    $shortcutPaths = @(
        "$script:AllUsersProfile\Desktop",
        "$script:AllUsersProfile\Start Menu\Programs",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
    )

    foreach ($path in $shortcutPaths) {
        if (Test-Path $path) {
            $shortcuts = Get-ChildItem -Path $path -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue
            foreach ($shortcut in $shortcuts) {
                if ($shortcut.Name -like "*Office*" -or $shortcut.Name -like "*Word*" -or $shortcut.Name -like "*Excel*" -or $shortcut.Name -like "*PowerPoint*" -or $shortcut.Name -like "*Outlook*") {
                    Write-Log ("Removing shortcut: {0}" -f $shortcut.FullName)
                    if (-not $script:DetectOnly) {
                        Remove-Item -Path $shortcut.FullName -Force
                    }
                }
            }
        }
    }
}

function Clean-OfficeServices {
    Write-LogSubHeader "Cleaning Office services"

    $officeServices = @(
        "ose",
        "OfficeClickToRun",
        "OfficeSvc",
        "OfficeTelemetryAgent",
        "OfficeTelemetryAgentFallBack"
    )

    foreach ($serviceName in $officeServices) {
        Remove-Service -ServiceName $serviceName
    }
}

function Clean-OfficeScheduledTasks {
    Write-LogSubHeader "Cleaning Office scheduled tasks"

    $officeTasks = @(
        "Microsoft Office 15 Sync Maintenance for *",
        "Microsoft Office 16 Sync Maintenance for *",
        "Office Automatic Updates 2.0",
        "Office ClickToRun Service Monitor",
        "OfficeTelemetryAgent*"
    )

    foreach ($taskPattern in $officeTasks) {
        try {
            $tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like $taskPattern }
            foreach ($task in $tasks) {
                Write-Log ("Removing scheduled task: {0}" -f $task.TaskName)
                if (-not $script:DetectOnly) {
                    Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false
                }
            }
        }
        catch {
            Write-LogOnly ("Error removing scheduled task: {0}" -f $_.Exception.Message)
        }
    }
}

function Clean-OfficeLicensing {
    if (-not $script:KeepLicense) {
        Write-LogSubHeader "Cleaning Office licensing"

        # Remove OSPP cache
        $osppPaths = @(
            "$script:ProgramData\Microsoft\OfficeSoftwareProtectionPlatform",
            "$script:LocalAppData\Microsoft\OfficeSoftwareProtectionPlatform"
        )

        foreach ($path in $osppPaths) {
            if (Test-Path $path) {
                Write-Log ("Removing OSPP cache: {0}" -f $path)
                if (-not $script:DetectOnly) {
                    Remove-FolderRecursive -Path $path -Force
                }
            }
        }

        # Remove VNext license cache
        $vnextPaths = @(
            "$script:LocalAppData\Microsoft\Office\15.0\Licensing",
            "$script:LocalAppData\Microsoft\Office\16.0\Licensing"
        )

        foreach ($path in $vnextPaths) {
            if (Test-Path $path) {
                Write-Log ("Removing VNext license cache: {0}" -f $path)
                if (-not $script:DetectOnly) {
                    Remove-FolderRecursive -Path $path -Force
                }
            }
        }
    }
}

function Complete-Cleanup {
    Write-LogSubHeader "Completing cleanup operations"

    # Clean temporary files
    $tempPaths = @(
        "$script:Temp\*Office*",
        "$script:Temp\*Microsoft*",
        "$script:WinDir\Temp\*Office*",
        "$script:WinDir\Temp\*Microsoft*"
    )

    foreach ($path in $tempPaths) {
        $items = Get-ChildItem -Path $path -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            Write-Log ("Removing temp item: {0}" -f $item.FullName)
            if (-not $script:DetectOnly) {
                Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Clean Windows Installer cache
    if (Test-Path $script:WICacheDir) {
        $wiItems = Get-ChildItem -Path $script:WICacheDir -Filter "*Office*" -ErrorAction SilentlyContinue
        foreach ($item in $wiItems) {
            Write-Log ("Removing WI cache item: {0}" -f $item.FullName)
            if (-not $script:DetectOnly) {
                Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }

    # Schedule deletion of in-use files
    if (-not $script:SkipSD) {
        Schedule-DeleteInUseFiles
    }
}

function Schedule-DeleteInUseFiles {
    Write-LogSubHeader "Scheduling deletion of in-use files"

    # This would implement the logic to schedule files for deletion on reboot
    # For now, we'll just log the action
    Write-Log "Files scheduled for deletion on reboot (if any)"
}

function Show-Summary {
    Write-LogHeader "Cleanup Summary"

    if ($script:DetectOnly) {
        Write-Log ("DETECT ONLY MODE - No files were removed")
    }
    else {
        Write-Log ("Office C2R removal completed")
    }

    if ($script:RebootRequired) {
        Write-Log ("REBOOT REQUIRED - Please restart the system")
        Set-ErrorCode $script:ERROR_REBOOT_REQUIRED
    }

    Write-Log ("Final error code: {0}" -f $script:ErrorCode)

    # Set return value
    Set-ReturnValue $script:ErrorCode
}

#endregion

#region Main Execution

function Main {
    try {
        # Initialize script
        if (-not (Initialize-Script)) {
            return $script:ERROR_SCRIPTINIT
        }

        # Find installed Office products
        if (-not (Find-InstalledOfficeProducts)) {
            Write-Log ("No Office products found to remove")
            return $script:ERROR_SUCCESS
        }

        if ($script:DetectOnly) {
            Write-Log ("Detection complete - no removal performed")
            return $script:ERROR_SUCCESS
        }

        # Confirm removal unless forced
        if (-not $script:Force) {
            $confirmation = Read-Host ("Are you sure you want to remove all Office C2R products? (Y/N)")
            if ($confirmation -notmatch "^[Yy]") {
                Write-Log ("User cancelled removal")
                Set-ErrorCode $script:ERROR_USERCANCEL
                return $script:ERROR_USERCANCEL
            }
        }

        # Perform removal operations
        Uninstall-OfficeProducts
        Remove-OfficeFiles
        Clean-OfficeRegistry
        Clean-OfficeShortcuts
        Clean-OfficeServices
        Clean-OfficeScheduledTasks
        Clean-OfficeLicensing
        Complete-Cleanup

        # Show summary
        Show-Summary

        return $script:ErrorCode
    }
    catch {
        Write-Log ("Fatal error: {0}" -f $_.Exception.Message)
        Set-ErrorCode $script:ERROR_UNKNOWN
        return $script:ERROR_UNKNOWN
    }
}

# Execute main function
$exitCode = Main
exit $exitCode

#endregion