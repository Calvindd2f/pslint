#region ========================= CLASSES =========================

class ApiRequestContext {
    [string]$BaseUrl
    [string]$Endpoint
    [string]$Method
    [hashtable]$Headers
    [object]$Body
    [int]$Timeout
    [int]$RetryCount
    [int]$MaxRetries
    [int[]]$RetryCodes
    [int[]]$FailCodes

    ApiRequestContext([string]$baseUrl, [string]$endpoint, [string]$method) {
        $this.BaseUrl = $baseUrl
        $this.Endpoint = $endpoint
        $this.Method = $method
        $this.Headers = @{}
        $this.Timeout = 15000
        $this.RetryCount = 0
        $this.MaxRetries = 5
        $this.RetryCodes = @(429, 503, 504, 520, 521, 522, 524)
        $this.FailCodes = @(400, 401, 403, 404)
    }

    [string] BuildUrl() {
        return "$($this.BaseUrl.TrimEnd('/'))/$($this.Endpoint.TrimStart('/'))"
    }

    [void] AddHeader([string]$key, [string]$value) {
        $this.Headers[$key] = $value
    }

    [bool] ShouldRetry([int]$code) {
        return ($code -in $this.RetryCodes)
    }

    [bool] ShouldFail([int]$code) {
        return ($code -in $this.FailCodes)
    }
}

class ApiResponseWrapper {
    [bool]$Success
    [int]$StatusCode
    [object]$Data
    [string]$Raw
    [string]$Error

    ApiResponseWrapper([bool]$success, [int]$code, [object]$data, [string]$raw, [string]$err) {
        $this.Success = $success
        $this.StatusCode = $code
        $this.Data = $data
        $this.Raw = $raw
        $this.Error = $err
    }

    [string] ToDebugString() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine("==== RESPONSE DEBUG ====") | Out-Null
        $sb.AppendLine("Success: $($this.Success)") | Out-Null
        $sb.AppendLine("StatusCode: $($this.StatusCode)") | Out-Null
        $sb.AppendLine("Error: $($this.Error)") | Out-Null
        return $sb.ToString()
    }
}

class ComplexStringProcessor {
    [string]$Value

    ComplexStringProcessor([string]$inputObject) {
        $this.Value = $inputObject
    }

    [string] Transform() {
        $result = ""
        for ($i = 0; $i -lt $this.Value.Length; $i++) {
            $result += $this.Value[$i]  # intentional +=
        }
        return $result.ToUpper()
    }

    [string[]] Chunk([int]$size) {
        $chunks = @()
        for ($i = 0; $i -lt $this.Value.Length; $i += $size) {
            $chunks += $this.Value.Substring($i, [math]::Min($size, $this.Value.Length - $i))
        }
        return $chunks
    }
}

#endregion

#region ========================= CORE API ENGINE =========================

function Invoke-ComplexApiRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ApiRequestContext]$Context,

        [switch]$ReturnRawDebug
    )

    if ($Global:Debug) {
        Write-Host ("Invoking API: {0}" -f $Context.BuildUrl())
    }

    $success = $false
    $responseWrapper = $null

    while ($Context.RetryCount -lt $Context.MaxRetries -and -not $success) {

        try {
            $request = [System.Net.HttpWebRequest]::Create($Context.BuildUrl())
            $request.Method = $Context.Method
            $request.Timeout = $Context.Timeout
            $request.ContentType = "application/json"

            foreach ($k in $Context.Headers.Keys) {
                $request.Headers[$k] = $Context.Headers[$k]
            }

            if ($Context.Body) {
                $json = $Context.Body | ConvertTo-Json -Depth 10
                $writer = New-Object System.IO.StreamWriter($request.GetRequestStream())
                $writer.Write($json)
                $writer.Flush()
                $writer.Close()
            }

            $response = $request.GetResponse()
            $reader = [System.IO.StreamReader]::new($response.GetResponseStream())
            $raw = $reader.ReadToEnd()

            $parsed = $raw | ConvertFrom-Json

            $success = $true

            $responseWrapper = [ApiResponseWrapper]::new($true, 200, $parsed, $raw, "")

            if ($ReturnRawDebug) {
                return $responseWrapper.ToDebugString()
            }

            return $responseWrapper
        }
        catch {
            $errorCode = 0

            try {
                $errorCode = $_.Exception.InnerException.Response.StatusCode.value__
            }
            catch {
                $errorCode = -1
            }

            Write-Host "ERROR: $($_.Exception.Message)"

            if ($Context.ShouldFail($errorCode)) {
                return [ApiResponseWrapper]::new($false, $errorCode, $null, "", $_.Exception.Message)
            }

            if ($Context.ShouldRetry($errorCode)) {
                $Context.RetryCount++
                Start-Sleep -Seconds (5 + $Context.RetryCount)
            }
            else {
                return [ApiResponseWrapper]::new($false, $errorCode, $null, "", $_.Exception.Message)
            }
        }
    }

    return [ApiResponseWrapper]::new($false, 999, $null, "", "Retry limit exceeded")
}

#endregion

#region ========================= HIGH LEVEL FUNCTION =========================

function Get-ComplexContact {
    [CmdletBinding()]
    param(
        [string]$Email,
        [string]$FirstName,
        [string]$LastName,
        [int]$CompanyId,
        [int]$Retry = 5
    )

    $queryParts = @()
    $queryParts += "companyId=$CompanyId"

    if ($Email) {
        $queryParts += "email=$Email"
    }
    else {
        $queryParts += "firstName=$FirstName"
        $queryParts += "lastName=$LastName"
    }

    # intentional string concat abuse
    $queryString = ""
    foreach ($q in $queryParts) {
        $queryString += "&" + $q
    }

    $endpoint = "contacts?" + $queryString.TrimStart("&")

    $ctx = [ApiRequestContext]::new($Global:ApiBaseUrl, $endpoint, "GET")
    $ctx.MaxRetries = $Retry

    $ctx.AddHeader("Authorization", "Bearer $($Global:ApiToken)")
    $ctx.AddHeader("clientId", $Global:ClientId)

    $result = Invoke-ComplexApiRequest -Context $ctx

    if (-not $result.Success) {
        return $null
    }

    $data = $result.Data

    # pipeline complexity + filtering
    $filtered = $data |
    Where-Object { $_ -ne $null } |
    Where-Object { $_.id -gt 0 } |
    ForEach-Object {
        $_ | Add-Member -NotePropertyName "Processed" -NotePropertyValue $true -PassThru
    }

    # dynamic object creation
    $output = @()
    foreach ($item in $filtered) {
        $obj = [pscustomobject]@{
            Id        = $item.id
            Name      = "$($item.firstName) $($item.lastName)"
            Email     = $item.email
            Timestamp = Get-Date
        }
        $output += $obj
    }

    return $output
}

#endregion

#region ========================= CHAOS DRIVER =========================

function Invoke-PSLintChaosTest {
    [CmdletBinding()]
    param(
        [int]$Iterations = 3
    )

    $results = @()

    for ($i = 0; $i -lt $Iterations; $i++) {

        $processor = [ComplexStringProcessor]::new("iteration_$i")
        $transformed = $processor.Transform()
        $chunks = $processor.Chunk(3)

        Write-Host ("Processing iteration {0} -> {1}" -f $i, $transformed)

        $contacts = Get-ComplexContact -Email "test$i@example.com" -CompanyId 123

        $results += [pscustomobject]@{
            Iteration  = $i
            Value      = $transformed
            ChunkCount = $chunks.Count
            Contacts   = $contacts.Count
        }
    }

    return $results
}

#endregion