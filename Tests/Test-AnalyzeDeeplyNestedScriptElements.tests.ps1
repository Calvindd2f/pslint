


# Ensure accurate analysis of deeply nested script elements
function Test-AnalyzeDeeplyNestedScriptElements
{
    # Arrange
    $scriptBlock = {
        $a = 1
        $b = 2
        $c = 3
        if ($a -eq 1)
        {
            if ($b -eq 2)
            {
                if ($c -eq 3)
                {
                    Write-Host "All conditions met"
                }
            }
        }
    }

    # Act
    $result = pslint -ScriptBlock $scriptBlock

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -Be 0
}