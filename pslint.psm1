function pslint {
    <#
    .SYNOPSIS
    Performance-focused PowerShell linter for analyzing scripts.

    .DESCRIPTION
    Analyzes a PowerShell script for performance issues. Supports PowerShell Core and Windows PowerShell.

    .PARAMETER Path
    The path to the script to analyze.

    .PARAMETER ScriptBlock
    The script block to analyze.

    .EXAMPLE
    Analyze a file:
    pslint -Path ".\your-script.ps1"

    Analyze a script block:
    $sb = { Write-Host "test" }
    pslint -ScriptBlock $sb

    .NOTES
            Author		: @Calvindd2f
            Site		: https://app-support.com
            File Name	: pslint
            Version     : 1.0
    #>
    [Alias('Scan-PowerShellScriptAdvanced')]
    [CmdletBinding()]
    PARAM (
        [Parameter(ParameterSetName = 'Path')]
        [ValidateScript({ $_ -match '(\.ps1$|\.psm1$)' })]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ScriptBlock')]
        [scriptblock]
        $ScriptBlock
    )

    BEGIN {
        $dllPath = "$PSScriptRoot\PslintLib.dll"
        if (Test-Path $dllPath) {
            Add-Type -Path $dllPath
        }
        else {
            throw "PslintLib.dll not found at: $dllPath"
        }
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            if (-not (Test-Path $Path)) {
                throw "File not found: $Path"
            }
        }
        else {
            if ($null -eq $ScriptBlock) {
                throw 'ScriptBlock cannot be null'
            }
        }
    }

    PROCESS {
        # Use the C# DLL for analysis
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $results = [PslintLib.Analysis.Analyzer]::AnalyzeFile($Path)
        }
        else {
            $results = [PslintLib.Analysis.Analyzer]::AnalyzeScriptBlock($ScriptBlock)
        }
    }

    END {
        $scriptPath = if ($PSCmdlet.ParameterSetName -eq 'Path') { $Path } else { $null }
        $report = [PslintLib.Analysis.ReportGenerator]::Generate($results, $scriptPath, [bool]$env:CI)
        return $report
    }
}