$modulePath = if ($env:PSLINT_TEST_MODULE_PATH) { $env:PSLINT_TEST_MODULE_PATH } else { "$PSScriptRoot\..\dist\pslint\pslint.psd1" }
Import-Module $modulePath -Force

Describe "pslint binary module validation" {
    It "Should analyze a valid script block without throwing" {
        { pslint -ScriptBlock { Write-Host "Hello World" } } | Should Not Throw
    }

    It "Should identify performance issues in an inefficient script" {
        $result = pslint -ScriptBlock { 1..100 | % { Write-Host $_ } }
        $result | Should Not BeNullOrEmpty
    }

}