Import-Module Pester -ErrorAction SilentlyContinue 
Import-Module ./dist/pslint/pslint.psd1 -Force
$res = Invoke-Pester ./Tests -PassThru
if ($res.FailedCount -gt 0) {
    $res.TestResult | Where-Object Passed -eq $false | Select-Object Name, FailureMessage, ErrorRecord | Format-List
} elseif ($null -ne $res.Failed) {
    # Pester 5
    $res.Failed | Select-Object Name, FailureMessage, ErrorRecord | Format-List
}
