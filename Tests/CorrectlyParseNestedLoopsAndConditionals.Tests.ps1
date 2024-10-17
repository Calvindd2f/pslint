
# Correctly parse nested loops and conditionals
function Test-CorrectlyParseNestedLoopsAndConditionals
{
    # Arrange
    $scriptBlock = {
        for ($i = 0; $i -lt 10; $i++)
        {
            if ($i % 2 -eq 0)
            {
                Write-Host "Even number: $i"
            }
            else
            {
                Write-Host "Odd number: $i"
            }
        }
    }

    # Act
    $result = pslint -ScriptBlock $scriptBlock

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -Be 0
}
