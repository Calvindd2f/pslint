#region Utilities
function Replace-Secret {
    <#
    .SYNOPSIS
    Replaces a specified string (such as a secret) in a file with a new string.
    .DESCRIPTION
    This function reads a file, replaces all occurrences of a specified old string with a new string, and writes the changes back to the file.
    .PARAMETER FilePath
    The path to the file where the replacement should occur.
    .PARAMETER OldString
    The string to be replaced.
    .PARAMETER NewString
    The string that will replace the old string.

    .EXAMPLE
    $filePath = "$PROFILE"
    $oldSecret = "this-is-a-test-credential-located-in-the-content-of-`$profile"
    $newSecret = "test-credential_newsecret-example"
    Replace-Secret -FilePath $filePath -OldString $oldSecret -NewString $newSecret

    .EXAMPLE
    Further capability can be obtained by scanning an entire folder tree and essentially 'cat'-ign each file and regex replacing the old secret with the newly created secret or even a null value.

    $files=gci -r -File;
    foreach ($f in $files){
        Replace-Secret -OldString $OldString -NewString $NewString -FilePath $f
    };
    if($NewString -notcontains 'null')
    {
        # A call or function to write this secret to Bitwarden or something similar .
    }

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$OldString,

        [Parameter(Mandatory = $true)]
        [string]$NewString
    )

    begin {
        if (-not (Test-Path -Path $FilePath)) {
            throw "File not found: $FilePath"
        }

        $content = Get-Content -Path $FilePath -Raw
    }

    process {
        try {
            $escapedOldString = [regex]::Escape($OldString)

            $pattern = "(?<=(?:'|\`"|=))$escapedOldString(?=(?:'|\`"))"

            $newContent = $content -replace $pattern, $NewString

            if ($newContent -eq $content) {
                [console]::WriteLine('No occurrences of the specified string were found in the file.')
            }
            else {
                Set-Content -Path $FilePath -Value $newContent
                [console]::WriteLine("Replacement complete in file: $FilePath")
            }
        }
        catch {
            throw "An error occurred: $($_.Exception.Message)"
        }
    }
}

Function Sign-Scripts($cert = (Get-ChildItem –Path Cert:\LocalMachine\My\31C4E1F8BAA0736E284BCD4FA91803457509308E), [string]$FilePath) {
    try {
        Set-AuthenticodeSignature -FilePath $FilePath -Certificate $cert -TimestampServer https://timestamp.digicert.com
    }
    catch {
        throw ($_.Exception.Message)
    }

    [console]::writeline(" | File: $FilePath has been signed with certificate: $cert.Subject | ")
}

class StringSlicer {
    [string]$StringValue

    StringSlicer([string]$initialValue) {
        $this.StringValue = $initialValue
    }

    [string] Slice([int]$start, [int]$length) {
        if ($length -eq 0 -or $start -ge $this.StringValue.Length) {
            return ''
        }
        $substring = $this.StringValue.Substring($start, [math]::Min($length, $this.StringValue.Length - $start))
        return $substring
    }
}

Function GetContact($email, $query, $companyid, $userObjectToAction, $retry = 5) {
    if ($Global:Debug) {
        [Console]::ForegroundColor = 'Yellow'
        [Console]::WriteLine($("`r`n`r`n==FUNC==CALLED===== -->{0}<--`r`n====ARGs=START======`r`n{1}`r`n====ARGs=END========`r`n" -f $MyInvocation.MyCommand, $(ConvertTo-Json $PSBoundParameters)))
    }
    if ($Global:Debug) { [Console]::WriteLine( "========================= GetContact params email, query, companyid,: $email, $query, $companyid,") }
    if ($query -eq 'Name') {
        $querystring = '?conditions=firstName="' + $($data.firstname) + '" AND lastName="' + $($data.lastname) + '"&company/id=' + $companyid
    }
    elseif ($query -eq 'Email') {
        # 2 things to note:
        # 1. We should use equal query here for email as this is uniq identifier. With 'LIKE' query we may catch many similar emails:
        # like '%name@domain.com%' will get emails name@domain.com, myname@domain.com, name@domain.com.au ...
        # 2. For the LIKE query - if the searched value starts with a number - it may conflict with url encoding later once transfered over HTTP, so the
        # use of '%25' (which is actual url encoded value of '%') encouraged.
        $querystring = '?childconditions=communicationItems/value="' + $($email) + '" AND communicationItems/communicationType="Email"' + '&conditions=company/id=' + $companyid
    }
    else {
        if ($Global:Debug) { [Console]::WriteLine( '========================= just before returning null') }
        return $null
    }
    if ($Global:Debug) { [Console]::WriteLine( "========================= querystring: $querystring") }


    $success = $false
    $WaitTime = 30
    $RetryCount = 0
    $RetryCodes = @(503, 504, 520, 521, 522, 524)
    $FailCodes = @(400, 404)
    while ($RetryCount -lt $retry -and $success -eq $false) {
        try {
            $request = [System.Net.HttpWebRequest]::Create("$CW_Api_Url/apis/3.0/company/contacts$querystring")

            $request.Method = 'GET';
            $request.ContentType = 'application/json';
            $authBytes = [System.Text.Encoding]::UTF8.GetBytes($CW_Api_Token);
            $authStr = 'Basic ' + $([System.Convert]::ToBase64String($authBytes));
            $request.Headers['Authorization'] = $authStr;
            $request.Headers['clientId'] = $CW_Api_Client_Id;
            $request.Timeout = 10000

            if ($Global:Debug) {
                $REQUEST = [System.Text.StringBuilder]::new();
                $REQUEST.AppendLine($("============================ HTTP REQUEST ============================$([Environment]::NewLine)"));
                $REQUEST.AppendLine($("HTTP Method:$([Environment]::NewLine){requestClone.Method}$([Environment]::NewLine)"));
                $REQUEST.AppendLine($("Absolute Uri:$([Environment]::NewLine){requestClone.RequestUri}$([Environment]::NewLine)"));
                $REQUEST.AppendLine($("Headers:$([Environment]::NewLine){HeadersToString(requestClone.Headers)}$([Environment]::NewLine)"));
                $REQUEST.AppendLine($("Body:$([Environment]::NewLine){SanitizeBody(body)}$([Environment]::NewLine)"));
                return $REQUEST.ToString();
            }

            $response = $request.GetResponse();
            $reader = [System.IO.StreamReader]::new($response.GetResponseStream());
            $jsonResult = $reader.ReadToEnd();
            $response.Dispose();

            if ($Global:Debug) {
                $RESPONSE = [System.Text.StringBuilder]::new();
                $RESPONSE.AppendLine($("============================ HTTP RESPONSE ============================$([Environment]::NewLine)"));
                $RESPONSE.AppendLine($("Status Code:$([Environment]::NewLine){response.StatusCode}$([Environment]::NewLine)"));
                $RESPONSE.AppendLine($("Headers:$([Environment]::NewLine){HeadersToString(response.Headers)}$([Environment]::NewLine)"));
                $RESPONSE.AppendLine($("Body:$([Environment]::NewLine){SanitizeBody(body)}$([Environment]::NewLine)"));

                if ($null -eq $RESPONSE) {
                    return [string]::Empty;
                }

                return $RESPONSE.ToString();
            }

            if ($Global:Debug) { [Console]::WriteLine( "========================= JSON result from WEB(GetContact): $jsonResult") }
            [array]$returnedObject = $jsonResult | ConvertFrom-Json
            if ($Global:Debug) { [Console]::WriteLine( "`r`n===================== Count of found objects: $($returnedObject.Count) `r`n") }

            if ($Global:Debug) {
                $INFO = [System.Text.StringBuilder]::new();
                $INFO.AppendLine($("================================ ERROR ================================$([Environment]::NewLine)"));
                $INFO.AppendLine($("{odataError?.Message}$([Environment]::NewLine)"));
                $INFO.AppendLine($("Status: {((int)response.StatusCode)} ({response.StatusCode})"));
                $INFO.AppendLine($("ErrorCode: {odataError?.Code}"));
                $INFO.AppendLine($("Date: {odataError?.InnerError?.Date}$([Environment]::NewLine)"));
                $INFO.AppendLine($("Headers:$([Environment]::NewLine){HeadersToString(response.Headers)}$([Environment]::NewLine)"));
                return $INFO.ToString();
            }

            if ($returnedObject.Count -gt 1) {
                foreach ($contactItem in $returnedObject) {
                    if ($Global:Debug) { Write-Host "=====================ContactItem===> $($contactItem)" }
                    if ($Global:Debug) { Write-Host "=====================ContactItem>>>> $($contactItem.id)" }
                    if ($Global:Debug) { Write-Host "=====================ContactItem>>>> $($contactItem.firstName) Compare to $($userObjectToAction.firstName)" }
                    if ($Global:Debug) { Write-Host "=====================ContactItem>>>> $($contactItem.lastName) Compare to $($userObjectToAction.lastName)" }
                    If (($contactItem.firstName -eq $userObjectToAction.firstName) -and ($contactItem.lastName -eq $userObjectToAction.lastName)) {
                        $success = $true
                        return $( $contactItem  )
                    }
                }
                $success = $true
                return $( $jsonResult | ConvertFrom-Json)
            }
            else {
                $success = $true
                return $( $jsonResult | ConvertFrom-Json)
            }

        }
        catch {
            if ($Global:Debug) { [Console]::WriteLine( "========================= WARNING: $($_.Exception.Message)") }
            [Console]::WriteLine( "========================= WARNING: $( ConvertTo-json $_.Exception)")
            # Geeting the actual numeric value for the error code.
            # When we run through Env we will get nested InnerException inside the
            # parent InnerException as we are utilising a HTTP WebClient Wrapper on top
            # of the environment
            if ( Test-Path variable:global:psISE ) {
                if ($Global:Debug) { [Console]::WriteLine( '==================Running package locally for debugging===========') }
                $ErrorCode = $_.Exception.InnerException.Response.StatusCode.value__
            }
            else {
                if ($Global:Debug) { [Console]::WriteLine( '========================= Running package in MxS') }
                $ErrorCode = $_.Exception.InnerException.InnerException.Response.StatusCode.value__
            }
            if ($Global:Debug) { [Console]::WriteLine( "========================= Errorcode: $ErrorCode") }
            # Checking if we got any of Fail Codes
            if ($ErrorCode -in $FailCodes) {
                # Setting the variables to make activity Fail
                $success = $false;
                $activityOutput.success = $false;
                # If we need immediate stop - we can uncomment below.
                # Write-Error "CRITICAL: $($_.Exception.Message)" -ErrorAction Stop
                Write-Warning "Warning: $($_.Exception.Message)"
                return $null;
            }
            if ($ErrorCode -in $RetryCodes) {
                $RetryCount++

                if ($RetryCount -eq $retry) {
                    if ($Global:Debug) { [Console]::WriteLine( '========================= WARNING: Retry limit reached.') }
                }
                else {
                    if ($Global:Debug) { [Console]::WriteLine( "========================= Waiting $WaitTime seconds.") }
                    Start-Sleep -Seconds $WaitTime
                    if ($Global:Debug) { [Console]::WriteLine( '========================= Retrying.') }
                }

            }
            else {
                return $null;
            }
        }
    }
    [Console]::ResetColor();
};
#endregion

#region variables
# Dynamics
$MSGRAPH_Api_Token_App;
$MSGRAPH_Api_Token_Client;

$EXO_Api_Token_App;
$EXO_Api_Token_Client;

$AZURE_Api_Token_Client;
$AZURE_Api_Token_App;

$RC_Api_Token
$RC_Bot_Token
$RC_Api_Sandbox_Token
$RC_Bot_Sandbox_Token

$Ctx_CW_Ticket_Id

# Constants
$Ctx_Client_MSTenant_Id;
$Ctx_Client_MSTenant_Name;
$Ctx_Client_Id

$SP_Url;
#endregion

#region TokenMgmt
# Token configuration class to store token metadata

class TokenConfig {
    [string]$Name
    [string]$Type  # App or Client
    [string]$Service # MSGRAPH, EXO, AZURE, RC
    [string]$Environment # Production or Sandbox
    [scriptblock]$RefreshFunction
    [datetime]$LastRefreshed
    [int]$ExpiryMinutes

    TokenConfig([string]$name, [string]$type, [string]$service, [int]$expiryMinutes) {
        $this.Name = $name
        $this.Type = $type
        $this.Service = $service
        $this.ExpiryMinutes = $expiryMinutes
        $this.LastRefreshed = Get-Date
    }
}

function Initialize-TokenManager {
    [CmdletBinding()]
    param()

    # Create global token registry
    $Global:TokenRegistry = @{
        # Microsoft Graph Tokens
        MSGRAPH_App    = [TokenConfig]::new("MSGRAPH_Api_Token_App", "App", "MSGRAPH", 60)
        MSGRAPH_Client = [TokenConfig]::new("MSGRAPH_Api_Token_Client", "Client", "MSGRAPH", 60)

        # Exchange Online Tokens
        EXO_App        = [TokenConfig]::new("EXO_Api_Token_App", "App", "EXO", 60)
        EXO_Client     = [TokenConfig]::new("EXO_Api_Token_Client", "Client", "EXO", 60)

        # Azure Tokens
        AZURE_App      = [TokenConfig]::new("AZURE_Api_Token_App", "App", "AZURE", 60)
        AZURE_Client   = [TokenConfig]::new("AZURE_Api_Token_Client", "Client", "AZURE", 60)

        # RingCentral Tokens
        RC_Api         = [TokenConfig]::new("RC_Api_Token", "Api", "RC", 60)
        RC_Bot         = [TokenConfig]::new("RC_Bot_Token", "Bot", "RC", 60)
        RC_Api_Sandbox = [TokenConfig]::new("RC_Api_Sandbox_Token", "Api", "RC", 60)
        RC_Bot_Sandbox = [TokenConfig]::new("RC_Bot_Sandbox_Token", "Bot", "RC", 60)
    }
}

function Debug-TokenStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$RefreshExpired,

        [Parameter(Mandatory = $false)]
        [switch]$Detailed
    )

    begin {
        if (-not $Global:TokenRegistry) {
            Initialize-TokenManager
        }
    }

    process {
        $results = @()

        foreach ($token in $Global:TokenRegistry.Keys) {
            $config = $Global:TokenRegistry[$token]
            $tokenValue = Get-Variable -Name $config.Name -ErrorAction SilentlyContinue

            $timeSinceRefresh = (Get-Date) - $config.LastRefreshed
            $isExpired = $timeSinceRefresh.TotalMinutes -gt $config.ExpiryMinutes

            $status = [PSCustomObject]@{
                Name             = $config.Name
                Service          = $config.Service
                Type             = $config.Type
                IsExpired        = $isExpired
                LastRefreshed    = $config.LastRefreshed
                TimeSinceRefresh = "{0:N2} minutes" -f $timeSinceRefresh.TotalMinutes
                HasValue         = ($null -ne $tokenValue)
            }

            if ($Detailed) {
                $status | Add-Member -MemberType NoteProperty -Name "Value" -Value $(
                    if ($tokenValue) { "<token present>" } else { "<no token>" }
                )
            }

            $results += $status

            if ($RefreshExpired -and $isExpired) {
                Write-Host "Refreshing expired token: $($config.Name)" -ForegroundColor Yellow
                try {
                    & $config.RefreshFunction
                    $config.LastRefreshed = Get-Date
                    Write-Host "Token refreshed successfully" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to refresh token: $_" -ForegroundColor Red
                }
            }
        }

        return $results | Format-Table -AutoSize
    }
}

function Register-TokenRefreshFunction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TokenName,

        [Parameter(Mandatory = $true)]
        [scriptblock]$RefreshFunction
    )

    if ($Global:TokenRegistry.ContainsKey($TokenName)) {
        $Global:TokenRegistry[$TokenName].RefreshFunction = $RefreshFunction
        Write-Host "Refresh function registered for token: $TokenName" -ForegroundColor Green
    }
    else {
        Write-Host "Token not found in registry: $TokenName" -ForegroundColor Red
    }
}

# Token refresh implementation for various services
class TokenRefreshResult {
    [bool]$Success
    [string]$Token
    [string]$_error

    TokenRefreshResult([bool]$success, [string]$token, [string]$_error = "") {
        $this.Success = $success
        $this.Token = $token
        $this._error = $_error
    }
}

function Initialize-TokenRefreshModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [hashtable]$ClientSecrets
    )

    # Store authentication configuration globally
    $Global:TokenRefreshConfig = @{
        TenantId      = $TenantId
        ClientId      = $ClientId
        ClientSecrets = $ClientSecrets
        Endpoints     = @{
            MSGraph            = "https://graph.microsoft.com"
            EXO                = "https://outlook.office365.com"
            Azure              = "https://management.azure.com"
            RingCentral        = "https://platform.ringcentral.com"
            RingCentralSandbox = "https://platform.devtest.ringcentral.com"
        }
    }
}

function Refresh-MSGraphToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("App", "Client")]
        [string]$TokenType
    )

    try {
        $config = $Global:TokenRefreshConfig
        $clientSecret = $config.ClientSecrets.MSGraph

        $body = @{
            client_id     = $config.ClientId
            client_secret = $clientSecret
            scope         = "https://graph.microsoft.com/.default"
            grant_type    = "client_credentials"
        }

        if ($TokenType -eq "Client") {
            # Add delegated auth specific parameters
            $body["grant_type"] = "refresh_token"
            $body["refresh_token"] = $Global:MSGRAPH_Api_Token_Client_Refresh
        }

        $response = Invoke-RestMethod -Method Post `
            -Uri "https://login.microsoftonline.com/$($config.TenantId)/oauth2/v2.0/token" `
            -Body $body `
            -ContentType "application/x-www-form-urlencoded"

        if ($TokenType -eq "App") {
            $Global:MSGRAPH_Api_Token_App = $response.access_token
        }
        else {
            $Global:MSGRAPH_Api_Token_Client = $response.access_token
            $Global:MSGRAPH_Api_Token_Client_Refresh = $response.refresh_token
        }

        return [TokenRefreshResult]::new($true, $response.access_token)
    }
    catch {
        return [TokenRefreshResult]::new($false, "", $_.Exception.Message)
    }
}

function Refresh-EXOToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("App", "Client")]
        [string]$TokenType
    )

    try {
        $config = $Global:TokenRefreshConfig
        $clientSecret = $config.ClientSecrets.EXO

        $body = @{
            client_id     = $config.ClientId
            client_secret = $clientSecret
            scope         = "https://outlook.office365.com/.default"
            grant_type    = "client_credentials"
        }

        if ($TokenType -eq "Client") {
            $body["grant_type"] = "refresh_token"
            $body["refresh_token"] = $Global:EXO_Api_Token_Client_Refresh
        }

        $response = Invoke-RestMethod -Method Post `
            -Uri "https://login.microsoftonline.com/$($config.TenantId)/oauth2/v2.0/token" `
            -Body $body `
            -ContentType "application/x-www-form-urlencoded"

        if ($TokenType -eq "App") {
            $Global:EXO_Api_Token_App = $response.access_token
        }
        else {
            $Global:EXO_Api_Token_Client = $response.access_token
            $Global:EXO_Api_Token_Client_Refresh = $response.refresh_token
        }

        return [TokenRefreshResult]::new($true, $response.access_token)
    }
    catch {
        return [TokenRefreshResult]::new($false, "", $_.Exception.Message)
    }
}

function Refresh-AzureToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("App", "Client")]
        [string]$TokenType
    )

    try {
        $config = $Global:TokenRefreshConfig
        $clientSecret = $config.ClientSecrets.Azure

        $body = @{
            client_id     = $config.ClientId
            client_secret = $clientSecret
            scope         = "https://management.azure.com/.default"
            grant_type    = "client_credentials"
        }

        if ($TokenType -eq "Client") {
            $body["grant_type"] = "refresh_token"
            $body["refresh_token"] = $Global:AZURE_Api_Token_Client_Refresh
        }

        $response = Invoke-RestMethod -Method Post `
            -Uri "https://login.microsoftonline.com/$($config.TenantId)/oauth2/v2.0/token" `
            -Body $body `
            -ContentType "application/x-www-form-urlencoded"

        if ($TokenType -eq "App") {
            $Global:AZURE_Api_Token_App = $response.access_token
        }
        else {
            $Global:AZURE_Api_Token_Client = $response.access_token
            $Global:AZURE_Api_Token_Client_Refresh = $response.refresh_token
        }

        return [TokenRefreshResult]::new($true, $response.access_token)
    }
    catch {
        return [TokenRefreshResult]::new($false, "", $_.Exception.Message)
    }
}

function Refresh-RingCentralToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Api", "Bot")]
        [string]$TokenType,

        [Parameter(Mandatory = $false)]
        [switch]$Sandbox
    )

    try {
        $config = $Global:TokenRefreshConfig
        $clientSecret = $config.ClientSecrets.RingCentral

        $baseUrl = if ($Sandbox) {
            $config.Endpoints.RingCentralSandbox
        }
        else {
            $config.Endpoints.RingCentral
        }

        # RingCentral uses Basic auth for token requests
        $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($config.ClientId):$clientSecret"))

        $headers = @{
            Authorization = "Basic $auth"
        }

        $body = @{
            grant_type    = "refresh_token"
            refresh_token = if ($TokenType -eq "Api") {
                if ($Sandbox) { $Global:RC_Api_Sandbox_Token_Refresh } else { $Global:RC_Api_Token_Refresh }
            }
            else {
                if ($Sandbox) { $Global:RC_Bot_Sandbox_Token_Refresh } else { $Global:RC_Bot_Token_Refresh }
            }
        }

        $response = Invoke-RestMethod -Method Post `
            -Uri "$baseUrl/restapi/oauth/token" `
            -Headers $headers `
            -Body $body `
            -ContentType "application/x-www-form-urlencoded"

        # Update the appropriate token based on type and environment
        switch ($TokenType) {
            "Api" {
                if ($Sandbox) {
                    $Global:RC_Api_Sandbox_Token = $response.access_token
                    $Global:RC_Api_Sandbox_Token_Refresh = $response.refresh_token
                }
                else {
                    $Global:RC_Api_Token = $response.access_token
                    $Global:RC_Api_Token_Refresh = $response.refresh_token
                }
            }
            "Bot" {
                if ($Sandbox) {
                    $Global:RC_Bot_Sandbox_Token = $response.access_token
                    $Global:RC_Bot_Sandbox_Token_Refresh = $response.refresh_token
                }
                else {
                    $Global:RC_Bot_Token = $response.access_token
                    $Global:RC_Bot_Token_Refresh = $response.refresh_token
                }
            }
        }

        return [TokenRefreshResult]::new($true, $response.access_token)
    }
    catch {
        return [TokenRefreshResult]::new($false, "", $_.Exception.Message)
    }
}

# Register all refresh functions with the token manager
function Register-AllTokenRefreshFunctions {
    [CmdletBinding()]
    param()

    Register-TokenRefreshFunction -TokenName "MSGRAPH_App" -RefreshFunction {
        return Refresh-MSGraphToken -TokenType "App"
    }

    Register-TokenRefreshFunction -TokenName "MSGRAPH_Client" -RefreshFunction {
        return Refresh-MSGraphToken -TokenType "Client"
    }

    Register-TokenRefreshFunction -TokenName "EXO_App" -RefreshFunction {
        return Refresh-EXOToken -TokenType "App"
    }

    Register-TokenRefreshFunction -TokenName "EXO_Client" -RefreshFunction {
        return Refresh-EXOToken -TokenType "Client"
    }

    Register-TokenRefreshFunction -TokenName "AZURE_App" -RefreshFunction {
        return Refresh-AzureToken -TokenType "App"
    }

    Register-TokenRefreshFunction -TokenName "AZURE_Client" -RefreshFunction {
        return Refresh-AzureToken -TokenType "Client"
    }

    Register-TokenRefreshFunction -TokenName "RC_Api" -RefreshFunction {
        return Refresh-RingCentralToken -TokenType "Api"
    }

    Register-TokenRefreshFunction -TokenName "RC_Bot" -RefreshFunction {
        return Refresh-RingCentralToken -TokenType "Bot"
    }

    Register-TokenRefreshFunction -TokenName "RC_Api_Sandbox" -RefreshFunction {
        return Refresh-RingCentralToken -TokenType "Api" -Sandbox
    }

    Register-TokenRefreshFunction -TokenName "RC_Bot_Sandbox" -RefreshFunction {
        return Refresh-RingCentralToken -TokenType "Bot" -Sandbox
    }
}
#endregion