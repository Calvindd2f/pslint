# Classify issues arising from improper use of loops
function Test-ClassifyImproperLoops
{
    # Arrange
    $scriptPath = "Test-PowerShellScript1.ps1"
    Set-Content -Path $scriptPath -Value 'foreach ($i in 1..20) { Write-Host $i }'

    # Act
    $result = pslint -Path $scriptPath

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -BeGreaterThan 0

    # Cleanup
    Remove-Item -Path $scriptPath
}