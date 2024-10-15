# Handle non-existent file paths gracefully
function Test-HandleNonExistentFilePath
{
    # Arrange
    $nonExistentPath = "non-existent-script.ps1"

    # Act & Assert
    { pslint -Path $nonExistentPath } | Should -Throw -ErrorMessage "File not found: $nonExistentPath"
}