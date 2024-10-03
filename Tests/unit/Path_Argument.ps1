
#region Hate my job
$path = [environemt]::currentdirectory;
#-------------------------------------------
[console]::ForegroundColor = [System.ConsoleColor]::Green;
[Console]::WriteLine("`$Path has been set - running path tests with directory ending in '' .");
[console]::ResetColor();
$path = $([environment]::currentdirectory)
[console]::Writeline("Running tests for: `
    -------------------------------`
    variable |  `$path `
    value`    |  $path
    test     |  Tests for directory . Not a file or a directory that ends with '\'
    ");
$path.EndsWith('')
$path.EndsWith('\')
$path.EndsWith('/')
$path.EndsWith("$null")
$path.EndsWith(' ')
$path.EndsWith('1')
$path.EndsWith('ps1')
$path.EndsWith('.')
$path.EndsWith('s1')
$path.EndsWith('\\')
$path.EndsWith('//')
$path.EndsWith('%5C')
Write-Output "$path"
# True
# C:\Users\c\Desktop\Function


#-------------------------------------------
[console]::ForegroundColor = [System.ConsoleColor]::Green;
[Console]::WriteLine("`$Path has been set - running path tests with directory ending in '\' .");
[console]::ResetColor();
$path = $([environment]::currentdirectory)
[console]::Writeline("Running tests for: `
-------------------------------`
variable |  `$path `
value`    |  $path
test     |  tests with directory ending in '\' , not a file or directory ending in ''
");

$path.EndsWith('')
$path.EndsWith('\')
$path.EndsWith('/')
$path.EndsWith("$null")
$path.EndsWith(' ')
$path.EndsWith('1')
$path.EndsWith('ps1')
$path.EndsWith('.')
$path.EndsWith('s1')
$path.EndsWith('\\')
$path.EndsWith('//')
$path.EndsWith('%5C')
Write-Output "$path"
# True
# C:\Users\c\Desktop\Function\
#-------------------------------------------
[console]::ForegroundColor = [System.ConsoleColor]::Green;
[Console]::WriteLine("`$Path has been set - running .ps1 file as Path tests.");
[console]::ResetColor();
$path = $([environment]::currentdirectory) + '\' + 'test.ps1'
[console]::Writeline("Running tests for: `
-------------------------------`
variable |  `$path `
value`    |  $path
test     |  When path input is a file, not a directory ending with `''` or directory ending in `\`
");

$path.EndsWith('')
$path.EndsWith('\')
$path.EndsWith('/')
$path.EndsWith("$null")
$path.EndsWith(' ')
$path.EndsWith('1')
$path.EndsWith('ps1')
$path.EndsWith('.')
$path.EndsWith('s1')
$path.EndsWith('\\')
$path.EndsWith('//')
$path.EndsWith('%5C')
Write-Output "$path"




#-------------------------------------------

#endregion

#region Recursion
    if ($Path)
    {
        if (Test-Path $Path)
        {
            if ($Path.EndsWith('1'))
            {
                [void](continue)
            }
            elseif ($Path.EndsWith('\') -or ($path.EndsWith('')))
            {
                [switch]$Recursive = $true
                [void](continue)
            }
            else
            {
                [System.Exception]::new().Message('Invalid input for Path. Must be a file or directory')
                throw [System.IO.IOException]::new().Message('Invalid Input.')
            }
        }
    }
    if ([switch]$Recursive)
    {
        $files = Get-ChildItem -R -Inc '*.ps1', '*.psm1'
    }
    if ($Debug)
    {
        [boolean]$global:pslintdebug = $true;
    }
    if ($Manual)
    {
        [void](Get-Help -Full pslint);
    }
    if ($All)
    {
        # This parameter is here for explanatory for the moment. It is defaulted to all tests are active.
        # I have it implemented and documented incase I want to introduce a method to specific which specific test the user wants to perform.
        # I will likely introduce a new string parameter with the test names in a [ParameterSet('test','test2','test3')] format.
        #TODO(@Calvindd2f):Please read comment and create issue.
        continue
    }
    elseif (!($All))
    {
        # This parameter is here for explanatory for the moment. It is defaulted to all tests are active.
        # I have it implemented and documented incase I want to introduce a method to specific which specific test the user wants to perform.
        # I will likely introduce a new string parameter with the test names in a [ParameterSet('test','test2','test3')] format.
        #TODO(@Calvindd2f):Please read comment and create issue.
        continue
    }





#endregion

#region Output
$Output = [environment]::CurrentDirectory + '\' + [datetime]::Now.ToString('dd-MM-yyyy hhmmz') + ' pslint_output.log';
If((Write-File $Output) -contains 'Exception')
{
    if ((New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
    {
        throw @"
        An exception has occured when attempting to write to the current directory: $([environment]::CurrentDirectory)
        You are currently in a standard priviledged process [even if you are an admin account].
        In order to write to the current directory you need to elevate the session.
        This should not happen in any directories within your user profile [ that is $($HOME) ]
        "
"@
    }
    elseif ($_.Exception.Message -contains '.NET','CLM','Constrained')
    {
        throw @"
            An exception has occured when attempting to write to the current directory: $([environment]::CurrentDirectory) .
            This is likely due to a .NET issue, or more aptly put. .NET method invocations being the cause of the blocker.
            Your PowerShell session is in CLM if you encounter this exception message.

            Invoking the following: `$($ExecutionContext.SessionState.LanguageMode)

            OUTPUT : $($ExecutionContext.SessionState.LanguageMode)

            Please correct by setting the value of the sessionstate to Full.

            'ICM $($ExecutionContext.SessionState.LanguageMode='FullLanguage')'
"@
    }
    else
    {
        throw ${$_.Exception.Message}
    }

}
#endregion

#region Decode Base64
if([switch]$DecodeB64.IsPresent -and ($Path.EndsWith('1')))
{
    $raw=Get-Content -Raw -Path $Path
    try
    {
        $expression64='^[-A-Za-z0-9+/]*={0,3}$'
        if([regex]::match($raw,$expression64))
        {
             $scriptContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($raw));
             $RemoveSignature = $true;

             try
             {
                if($RemoveSignature -eq $true)
                {
                    $x = $scriptContent.IndexOf("# SIG # Begin signature block")
                    if($x -gt 0)
                    {
                        $scriptContent = $scriptContent.SubString(0,$x)
                        $scriptContent = $scriptContent + "# SIG # Begin signature block`nSignature data excluded..."
                    }
                }

                try
                {
                    $tempfile="$PSScriptRoot.ToString() + $([datetime]::now.tostring('dd-MM-yyyy_hhmm')) + 'base64.ps1'"
                    New-Item -Type File "$tempfile="$PSScriptRoot.ToString() + $([datetime]::now.tostring('dd-MM-yyyy_hhmm_tmpb64'))"" -Force
                    $scriptcontent > $tempfile="$PSScriptRoot.ToString() + $([datetime]::now.tostring('dd-MM-yyyy_hhmm_tmpb64'))"
                }
                catch
                {
                    throw $_.Exception.Message
                }

            } catch
            {
                 throw ${$_.Exception.Message}
            }
        }
        else
        {
            Remove-Variable -name 'expression64';
            [console]::writeline('File is not a base64 string, error being caught with a failover expression.')
        }

    }
    catch
    {
        $fallback_expression64='^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$'
        if([regex]::match($raw,$expression64))
        {
            $scriptContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($raw));
            $RemoveSignature = $true;
            try
            {
                if($RemoveSignature -eq $true)
                {
                    $x = $scriptContent.IndexOf("# SIG # Begin signature block")if($x -gt 0)
                    {
                        $scriptContent = $scriptContent.SubString(0,$x)
                        $scriptContent = $scriptContent + "# SIG # Begin signature block`nSignature data excluded..."
                    }
                }
                else
                {
                    Remove-Variable -name 'fallback_expression64';
                    [gc]::WaitForPendingFinalizers();
                    [GC]::COllect;
                    throw @"
                    File contents are not Base 64 string or RFC Base64 contents. Unable to decode.
                    Details:
                    $($_.Exception.Message)
"@
                }
            }
            catch
            {
                throw ${$_.Exception.Message}
            }

            try
            {
                $tempfile=""$env:TEMP" + '\' +  $PSScriptRoot.ToString() + $([datetime]::now.tostring('dd-MM-yyyy_hhmm')) + 'base64.ps1'"
                New-Item -Type File "$tempfile"
                $scriptcontent > "$tempfile"
            }

            catch
            {
                throw ${$_.Exception.Message}
            }
        }
    }
    $Path=$tempfile
    try
    {
        pslint -Path $Path -Output "Decoded_pslint_output_report.txt"
    }
    catch
    {
        $Error[0]
    }
    # Leftover File
    Remove-Item $Path -Force -ErrorAction SilentlyContinue
    # Leftover Variables
    Remove-Variable Path -Force -ErrorAction SilentlyContinue
    Remove-Variable scriptcontent -Force -ErrorAction SilentlyContinue
    Remove-Variable tempfile -Force -ErrorAction SilentlyContinue
    Remove-Variable fallback_expression64 -Force -ErrorAction SilentlyContinue
    Remove-Variable expression64 -Force -ErrorAction SilentlyContinue
    Remove-Variable raw -Force -ErrorAction SilentlyContinue
    # Mr RAM will appreciate this
    [gc]::WaitForPendingFinalizers
    [gc]::Collect()
}
#endregion