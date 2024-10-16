# HttpClient
$client = [System.Net.Http.HttpClient]::new()
$request = [System.Net.Http.HttpRequestMessage]::new('POST', 'https://localhost')
$request.Headers.Add('key', '')
$response = $client.SendAsync($request);
$response.IsCompletedSuccessfully
[Console]::WriteLine($response.Content.ReadAsStringAsync());


# Invoke-RestMethod
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Cookie", "csv=2; edgebucket=I62qVg0y6tYHZgZafa; loid=0000000019yq9q4pm5.2.1727820497011.Z0FBQUFBQm1fSExSbGFOR2NKdllKcVhBMV9BdEdvQllzcEtPUEJ4b3FEQVZZc1Z2Q1hKeENCemxSOUJ5TkJqZE80ZEswb2xRdUVEZ0dCcnhyMXFKMHpkZ1JVeDZpeS1XRTNubnpaS213VEpPYmxYak1hdDAxTXpvdXhQcE9xSTBPSE1oV1BFcVRXSDk")
$response = Invoke-RestMethod 'https://www.reddit.com/api/v1/authorize?client_id=CK1NfrFZORI0dsb0iIMBWg&response_type=code&state=yrtyryrt&redirect_uri=https://localhost&duration=permanent&scope=read' -Method 'GET' -Headers $headers
$response | ConvertTo-Json

# New-SpecificBlogPost

Function new-post
{
    PARAM(
        [string]$title = 'My First Blog Post',
        [string]$published = [datetime]::Now.tostring('yyyy-MM-dd'),
        [string]$description = 'This is the first post of my new Astro blog.',
        [string]$image,
        [string]$tags = '[Foo, Bar]',
        [string]$category = 'Front-end',
        [string]$draft = 'false',
        [string]$lang = 'en'                  # Set only if the post's language differs from the site's language in `config.ts`
    )

    $blogdir = 'C:\Users\c\effective-memory\src\content\posts'

    if (!$title)
    {
        $rng = [guid]::newguid()
        $title = Join-String -OutputPrefix "entry-" -OutputSuffix $rng
        $filename = $title
    }
    elseif ($title)
    {
        $filename = $title.trim(' ')
    }

    $out = "$blogdir\$filename.md"

    ni $out -Force;

    $sb = [System.Text.StringBuilder]::new()
    [void]($sb.AppendLine('---'))
    [void]($sb.AppendLine("title: $title"))
    [void]($sb.AppendLine("published: $published"))
    [void]($sb.AppendLine("description: $description"))
    if ($image)
    {
        [void]($sb.AppendLine("image: $image"))
    }
    [void]($sb.AppendLine("tags: $tags"))
    [void]($sb.AppendLine("draft: $draft"))
    [void]($sb.AppendLine("category: $category"))
    [void]($sb.AppendLine("lang: $lang"));
    [void]($sb.AppendLine('---'))

    $s = $sb.ToString();
    $sb.Clear();
    [GC]::Collect();
    $s>>$out

    return

}
Function new-bd
{
    PARAM(
        [string]$title = 'My First Blog Post',
        [string]$published = [datetime]::Now.tostring('yyyy-MM-dd'),
        [string]$description = 'Entries from the BD archive. Before it likely gets Shoah"d.',
        [string]$tags = '[Ireland]',
        [string]$category = 'Blackdwarf',
        [string]$draft = 'false',
        [string]$lang = 'en'                  # Set only if the post's language differs from the site's language in `config.ts`
    )

    $blogdir = 'C:\Users\c\effective-memory\src\content\posts\Blackdwarf'

    if (!$title)
    {
        $rng = [guid]::newguid()
        $title = Join-String -OutputPrefix "entry-" -OutputSuffix $rng
        $filename = $title
    }
    elseif ($title)
    {
        $filename = $title.trim(' ')
    }

    $out = "$blogdir\$filename.md"

    ni $out -Force;

    $sb = [System.Text.StringBuilder]::new()
    [void]($sb.AppendLine('---'))
    [void]($sb.AppendLine("title: $title"))
    [void]($sb.AppendLine("published: $published"))
    [void]($sb.AppendLine("description: $description"))
    if ($image)
    {
        [void]($sb.AppendLine("image: $image"))
    }
    [void]($sb.AppendLine("tags: $tags"))
    [void]($sb.AppendLine("draft: $draft"))
    [void]($sb.AppendLine("category: $category"))
    [void]($sb.AppendLine("lang: $lang"));
    [void]($sb.AppendLine('---'))
    $null|Out-Null
    $s = $sb.ToString();
    $sb.Clear();
    [GC]::Collect();
    $s>>$out| Out-Null

    return

}




# 1Line
[System.Collections.Generic.Dictionary[[String], [String]]]::new() >$null


# SnD
function Search-ReplaceInFiles
{
    param (
        [Parameter()]
        [string]$FolderPath = [System.Environment]::CurrentDirectory,

        [Parameter(Mandatory = $true)]
        [string]$SearchKeyword,

        [Parameter(Mandatory = $true)]
        [string]$ReplaceWith,

        [Parameter(Mandatory = $false)]
        [string]$FileFilter = "*.*"
    )

    if (-not (Test-Path -Path $FolderPath))
    {
        Write-Error "Folder path does not exist: $FolderPath" > $null
        return
    }

    try
    {
        $files = Get-ChildItem -Path $FolderPath -Filter $FileFilter -File -Recurse | Out-Null

        foreach ($file in $files)
        {
            Write-Host "Processing file: $($file.FullName)"

            $content = Get-Content -Path $file.FullName -Raw

            if ($content -match [regex]::Escape($SearchKeyword))
            {
                Write-Host "Found match in: $($file.FullName)" -ForegroundColor Green

                $newContent = $content -replace [regex]::Escape($SearchKeyword), $ReplaceWith

                ($null -eq $newContent | Set-Content -Path $file.FullName -Force)

                Write-Host "Replaced '$SearchKeyword' with '$ReplaceWith'" -ForegroundColor Yellow
            }
        }
    }
    catch
    {
        Write-Error "An error occurred: $_"
    }
};

function Replace-Secret
{
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

    begin
    {
        if (-not (Test-Path -Path $FilePath))
        {
            throw "File not found: $FilePath"
        }

        $content = Get-Content -Path $FilePath -Raw
    }

    process
    {
        try
        {
            $escapedOldString = [regex]::Escape($OldString)

            $pattern = "(?<=(?:'|\`"|=))$escapedOldString(?=(?:'|\`"))"

            $newContent = $content -replace $pattern, $NewString

            if ($newContent -eq $content)
            {
                [console]::WriteLine('No occurrences of the specified string were found in the file.')
            }
            else
            {
                Set-Content -Path $FilePath -Value $newContent
                [console]::WriteLine("Replacement complete in file: $FilePath")
            }
        }
        catch
        {
            throw "An error occurred: $($_.Exception.Message)"
        }
    }
}

Function Sign-Scripts($cert = (Get-ChildItem –Path Cert:\LocalMachine\My\31C4E1F8BAA0736E284BCD4FA91803457509308E), [string]$FilePath)
{
    try
    {
        Set-AuthenticodeSignature -FilePath $FilePath -Certificate $cert -TimestampServer https://timestamp.digicert.com
    }
    catch
    {
        throw ($_.Exception.Message)
    }

    [console]::writeline(" | File: $FilePath has been signed with certificate: $cert.Subject | ")
}

class StringSlicer
{
    [string]$StringValue

    StringSlicer([string]$initialValue)
    {
        $this.StringValue = $initialValue
    }

    [string] Slice([int]$start, [int]$length)
    {
        if ($length -eq 0 -or $start -ge $this.StringValue.Length)
        {
            return ''
        }
        $substring = $this.StringValue.Substring($start, [math]::Min($length, $this.StringValue.Length - $start))
        return $substring
    }
}

Function GetContact($email, $query, $companyid, $userObjectToAction, $retry = 5)
{
    if ($Global:Debug)
    {
        [Console]::ForegroundColor = 'Yellow'
        [Console]::WriteLine($("`r`n`r`n==FUNC==CALLED===== -->{0}<--`r`n====ARGs=START======`r`n{1}`r`n====ARGs=END========`r`n" -f $MyInvocation.MyCommand, $(ConvertTo-Json $PSBoundParameters)))
    }
    if ($Global:Debug) { [Console]::WriteLine( "========================= GetContact params email, query, companyid,: $email, $query, $companyid,") }
    if ($query -eq 'Name')
    {
        $querystring = '?conditions=firstName="' + $($data.firstname) + '" AND lastName="' + $($data.lastname) + '"&company/id=' + $companyid
    }
    elseif ($query -eq 'Email')
    {
        # 2 things to note:
        # 1. We should use equal query here for email as this is uniq identifier. With 'LIKE' query we may catch many similar emails:
        # like '%name@domain.com%' will get emails name@domain.com, myname@domain.com, name@domain.com.au ...
        # 2. For the LIKE query - if the searched value starts with a number - it may conflict with url encoding later once transfered over HTTP, so the
        # use of '%25' (which is actual url encoded value of '%') encouraged.
        $querystring = '?childconditions=communicationItems/value="' + $($email) + '" AND communicationItems/communicationType="Email"' + '&conditions=company/id=' + $companyid
    }
    else
    {
        if ($Global:Debug) { [Console]::WriteLine( '========================= just before returning null') }
        return $null
    }
    if ($Global:Debug) { [Console]::WriteLine( "========================= querystring: $querystring") }


    $success = $false
    $WaitTime = 30
    $RetryCount = 0
    $RetryCodes = @(503, 504, 520, 521, 522, 524)
    $FailCodes = @(400, 404)
    while ($RetryCount -lt $retry -and $success -eq $false)
    {
        try
        {
            $request = [System.Net.HttpWebRequest]::Create("$CW_Api_Url/apis/3.0/company/contacts$querystring")

            $request.Method = 'GET';
            $request.ContentType = 'application/json';
            $authBytes = [System.Text.Encoding]::UTF8.GetBytes($CW_Api_Token);
            $authStr = 'Basic ' + $([System.Convert]::ToBase64String($authBytes));
            $request.Headers['Authorization'] = $authStr;
            $request.Headers['clientId'] = $CW_Api_Client_Id;
            $request.Timeout = 10000

            if ($Global:Debug)
            {
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

            if ($Global:Debug)
            {
                $RESPONSE = [System.Text.StringBuilder]::new();
                $RESPONSE.AppendLine($("============================ HTTP RESPONSE ============================$([Environment]::NewLine)"));
                $RESPONSE.AppendLine($("Status Code:$([Environment]::NewLine){response.StatusCode}$([Environment]::NewLine)"));
                $RESPONSE.AppendLine($("Headers:$([Environment]::NewLine){HeadersToString(response.Headers)}$([Environment]::NewLine)"));
                $RESPONSE.AppendLine($("Body:$([Environment]::NewLine){SanitizeBody(body)}$([Environment]::NewLine)"));

                if ($null -eq $RESPONSE)
                {
                    return [string]::Empty;
                }

                return $RESPONSE.ToString();
            }

            if ($Global:Debug) { [Console]::WriteLine( "========================= JSON result from WEB(GetContact): $jsonResult") }
            [array]$returnedObject = $jsonResult | ConvertFrom-Json
            if ($Global:Debug) { [Console]::WriteLine( "`r`n===================== Count of found objects: $($returnedObject.Count) `r`n") }

            if ($Global:Debug)
            {
                $INFO = [System.Text.StringBuilder]::new();
                $INFO.AppendLine($("================================ ERROR ================================$([Environment]::NewLine)"));
                $INFO.AppendLine($("{odataError?.Message}$([Environment]::NewLine)"));
                $INFO.AppendLine($("Status: {((int)response.StatusCode)} ({response.StatusCode})"));
                $INFO.AppendLine($("ErrorCode: {odataError?.Code}"));
                $INFO.AppendLine($("Date: {odataError?.InnerError?.Date}$([Environment]::NewLine)"));
                $INFO.AppendLine($("Headers:$([Environment]::NewLine){HeadersToString(response.Headers)}$([Environment]::NewLine)"));
                return $INFO.ToString();
            }

            if ($returnedObject.Count -gt 1)
            {
                foreach ($contactItem in $returnedObject)
                {
                    if ($Global:Debug) { Write-Host "=====================ContactItem===> $($contactItem)" }
                    if ($Global:Debug) { Write-Host "=====================ContactItem>>>> $($contactItem.id)" }
                    if ($Global:Debug) { Write-Host "=====================ContactItem>>>> $($contactItem.firstName) Compare to $($userObjectToAction.firstName)" }
                    if ($Global:Debug) { Write-Host "=====================ContactItem>>>> $($contactItem.lastName) Compare to $($userObjectToAction.lastName)" }
                    If (($contactItem.firstName -eq $userObjectToAction.firstName) -and ($contactItem.lastName -eq $userObjectToAction.lastName))
                    {
                        $success = $true
                        return $( $contactItem  )
                    }
                }
                $success = $true
                return $( $jsonResult | ConvertFrom-Json)
            }
            else
            {
                $success = $true
                return $( $jsonResult | ConvertFrom-Json)
            }

        }
        catch
        {
            $nil=out-null | out-null | out-null
            echo $nil |out-null
            write-host $nil;
            if ($Global:Debug) { [Console]::WriteLine( "========================= WARNING: $($_.Exception.Message)") }
            [Console]::WriteLine( "========================= WARNING: $( ConvertTo-json $_.Exception)")
            # Geeting the actual numeric value for the error code.
            # When we run through Env we will get nested InnerException inside the
            # parent InnerException as we are utilising a HTTP WebClient Wrapper on top
            # of the environment
            if ( Test-Path variable:global:psISE )
            {
                if ($Global:Debug) { [Console]::WriteLine( '==================Running package locally for debugging===========') }
                $ErrorCode = $_.Exception.InnerException.Response.StatusCode.value__
            }
            else
            {
                if ($Global:Debug) { [Console]::WriteLine( '========================= Running package in MxS') }
                $ErrorCode = $_.Exception.InnerException.InnerException.Response.StatusCode.value__
            }
            if ($Global:Debug) { [Console]::WriteLine( "========================= Errorcode: $ErrorCode") }
            # Checking if we got any of Fail Codes
            if ($ErrorCode -in $FailCodes)
            {
                # Setting the variables to make activity Fail
                $success = $false;
                $activityOutput.success = $false;
                # If we need immediate stop - we can uncomment below.
                # Write-Error "CRITICAL: $($_.Exception.Message)" -ErrorAction Stop
                Write-Warning "Warning: $($_.Exception.Message)"
                return $null;
            }
            if ($ErrorCode -in $RetryCodes)
            {
                $RetryCount++

                if ($RetryCount -eq $retry)
                {
                    if ($Global:Debug) { [Console]::WriteLine( '========================= WARNING: Retry limit reached.') }
                }
                else
                {
                    if ($Global:Debug) { [Console]::WriteLine( "========================= Waiting $WaitTime seconds.") }
                    Start-Sleep -Seconds $WaitTime
                    if ($Global:Debug) { [Console]::WriteLine( '========================= Retrying.') }
                }

            }
            else
            {
                return $null;
            }
        }
    }
    [Console]::ResetColor();
};
