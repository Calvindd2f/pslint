

# Handle recursive structures without errors
function Test-HandleRecursiveStructuresWithoutErrors
{
    # Arrange
    $scriptBlock = {
        $obj = New-Object psobject
        $obj | Add-Member -MemberType NoteProperty -Name "Name" -Value "John"
        $obj | Add-Member -MemberType NoteProperty -Name "Age" -Value 30
        $obj | Add-Member -MemberType NoteProperty -Name "Children" -Value @(
            @{
                "Name"     = "Alice"
                "Age"      = 10
                "Children" = @(
                    @{
                        "Name"     = "Bob"
                        "Age"      = 5
                        "Children" = @()
                    }
                )
            }
        )
        $obj
    }

    # Act
    $result = pslint -ScriptBlock $scriptBlock

    # Assert
    $result | Should -Not -BeNullOrEmpty
    $result.Summary.TotalIssues | Should -Be 0
}