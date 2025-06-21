# Validate that the SummaryOnly switch suppresses detailed output
function Test-SummaryOnlySwitch
{
    # Arrange
    Import-Module ../pslint.psm1 -Force
    $scriptBlock = { Write-Host "Test" }

    # Act
    $output = pslint -ScriptBlock $scriptBlock -SummaryOnly
    $joined = $output -join "`n"

    # Assert
    $joined | Should -Match 'Total Issues Found'
    $joined | Should -Not -Match 'Code:'
}
