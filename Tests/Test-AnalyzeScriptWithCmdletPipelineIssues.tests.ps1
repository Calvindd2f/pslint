

# Detect and categorize issues with cmdlet pipeline usage
function Test-AnalyzeScriptWithCmdletPipelineIssues
{
    # Arrange
    $scriptPath = "Test-PowerShellScript1.ps1"
    Set-Content -Path $scriptPath -Value 'Get-ChildItem | ForEach-Object { $_ }'

    # Act
    $result = pslint -Path $scriptPath

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -BeGreaterThan 0

    # Cleanup
    Remove-Item -Path $scriptPath
}