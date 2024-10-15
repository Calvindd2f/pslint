# Identify performance issues related to large data collections
function Test-IdentifyLargeDataCollectionPerformanceIssues
{
    # Arrange
    $scriptBlock = {
        $largeCollection = @{}
        1..10000 | ForEach-Object {
            $largeCollection.Add($_, "Item $_")
        }
    }

    # Act
    $result = pslint -ScriptBlock $scriptBlock

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -BeGreaterThan 0
}