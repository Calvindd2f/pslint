New-Module -Name TestHelpers -ScriptBlock {
    function InPesterModuleScope
    {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory = $true)]
            [scriptblock]
            $ScriptBlock
        )

        $module = Get-Module -Name Pester -ErrorAction Stop
        . $module $ScriptBlock
    }

    function New-Dictionary ([hashtable]$Hashtable)
    {
        $d = [System.Collections.Generic.Dictionary[string, object]]::new()
        $Hashtable.GetEnumerator() | ForEach-Object { $d.Add($_.Key, $_.Value) }

        $d
    }

    function Clear-WhiteSpace ($Text)
    {
        "$($Text -replace "(`t|`n|`r)"," " -replace "\s+"," ")".Trim()
    }
} | Out-Null


$configuration = [PesterConfiguration]::Default

$configuration.Output.Verbosity = "Normal"
$configuration.Debug.WriteDebugMessages = $false
$configuration.Debug.WriteDebugMessagesFrom = 'CodeCoverage'

$configuration.Debug.ShowFullErrors = $false
$configuration.Debug.ShowNavigationMarkers = $false

if ($null -ne $File -and 0 -lt @($File).Count)
{
    $configuration.Run.Path = $File
}
else
{
    $configuration.Run.Path = "$PSScriptRoot/tst"
}
$configuration.Run.ExcludePath = '*/demo/*', '*/examples/*', '*/testProjects/*'
$configuration.Run.PassThru = $true

$configuration.Filter.ExcludeTag = 'VersionChecks', 'StyleRules'

if ($CI)
{
    $configuration.Run.Exit = $true

    # not using pester code coverage, because we measure it externally, see CC switch
    $configuration.CodeCoverage.Enabled = $false

    $configuration.TestResult.Enabled = $true
}

$r = Invoke-Pester -Configuration $configuration

if ($CC)
{
    try
    {
        $Write_CoverageReport = & (Get-Module Pester) { Get-Command Write-CoverageReport }
        $Stop_TraceScript = & (Get-Module Pester) { Get-Command Stop-TraceScript }
        $Get_CoverageReport = & (Get-Module Pester) { Get-Command Get-CoverageReport }
        $Get_JaCoCoReportXml = & (Get-Module Pester) { Get-Command Get-JaCoCoReportXml }

        & $Stop_TraceScript -Patched $patched
        $measure = $tracer.Hits
        $coverageReport = & $Get_CoverageReport -CommandCoverage $breakpoints -Measure $measure
    }
    finally
    {
        if ($null -ne $bp)
        {
            $bp | Remove-PSBreakpoint
        }
    }

    [xml] $jaCoCoReport = [xml] (& $Get_JaCoCoReportXml -CommandCoverage $breakpoints -TotalMilliseconds $sw.ElapsedMilliseconds -CoverageReport $coverageReport -Format "JaCoCo")
    $jaCoCoReport.OuterXml | Set-Content -Path $PSScriptRoot/coverage.xml
    & $Write_CoverageReport -CoverageReport $coverageReport
}

if ("Failed" -eq $r.Result)
{
    throw "Run failed!"
}