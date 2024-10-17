


# Handle scripts with mixed PowerShell and .NET elements
function Test-AnalyzeScriptWithMixedElements
{
    # Arrange
    $scriptBlock = {
        Write-Host "Testing script block"
    }

    # Act
    $result = pslint -ScriptBlock $scriptBlock

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -Be 0
}