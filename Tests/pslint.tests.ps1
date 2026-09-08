$modulePath = if ($env:PSLINT_TEST_MODULE_PATH) { $env:PSLINT_TEST_MODULE_PATH } else { "$PSScriptRoot\..\dist\pslint\pslint.psd1" }
Import-Module $modulePath -Force

Describe "pslint binary module validation" {
    It "Should analyze a valid script block without throwing" {
        { pslint -ScriptBlock { Write-Host "Hello World" } } | Should -Not -Throw
    }

    It "Should identify performance issues in an inefficient script" {
        $result = pslint -ScriptBlock { 1..100 | % { Write-Host $_ } }
        $result | Should -Not -BeNullOrEmpty
    }

}

Describe "pslint maintainability rules" {
    It "Should flag a risky API call not wrapped in try/catch" {
        $result = pslint -ScriptBlock { Invoke-RestMethod -Uri "https://example.com" }
        $result.Summary.Categories.Keys | Should -Contain "MissingErrorHandling"
    }

    It "Should not flag a risky API call that is wrapped in try/catch" {
        $result = pslint -ScriptBlock {
            try { Invoke-RestMethod -Uri "https://example.com" } catch { throw }
        }
        $result.Summary.Categories.Keys | Should -Not -Contain "MissingErrorHandling"
    }

    It "Should flag a mandatory function parameter with no validation" {
        $result = pslint -ScriptBlock {
            function Get-Thing {
                param(
                    [Parameter(Mandatory = $true)]
                    $Name
                )
                $Name
            }
        }
        $result.Summary.Categories.Keys | Should -Contain "MissingParameterValidation"
    }

    It "Should not flag a mandatory function parameter that has a type constraint" {
        $result = pslint -ScriptBlock {
            function Get-Thing {
                param(
                    [Parameter(Mandatory = $true)]
                    [string]$Name
                )
                $Name
            }
        }
        $result.Summary.Categories.Keys | Should -Not -Contain "MissingParameterValidation"
    }

    It "Should not flag a parameter explicitly marked Mandatory = `$false" {
        $result = pslint -ScriptBlock {
            function Get-Thing {
                param(
                    [Parameter(Mandatory = $false)]
                    $Name
                )
                $Name
            }
        }
        $result.Summary.Categories.Keys | Should -Not -Contain "MissingParameterValidation"
    }

    It "Should flag a statement block duplicated three or more times" {
        $result = pslint -ScriptBlock {
            Write-Output "the same statement"
            Write-Output "the same statement"
            Write-Output "the same statement"
        }
        $result.Summary.Categories.Keys | Should -Contain "DuplicatedCodeBlocks"
    }

    It "Should not flag statements that are not duplicated" {
        $result = pslint -ScriptBlock {
            Write-Output "first statement"
            Write-Output "second statement"
        }
        $result.Summary.Categories.Keys | Should -Not -Contain "DuplicatedCodeBlocks"
    }
}