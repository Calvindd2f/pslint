@{
    RootModule           = 'pslint'

    Author               = 'Calvin Bergin <Calvindd2f>'

    CompanyName          = n/a

    ModuleVersion        = '1'

    GUID                 = 'bc931fbd-b205-45be-9ecf-4f9db144998b'

    Copyright            = '2024 Calvindd2f'

    Description          = 'Performance focused linter for PowerShell scripts and Modules'

    PowerShellVersion    = '5.1'

    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport    = @('pslint')

    AliasesToExport      = @('Scan-PowerShellScriptAdvanced')

    VariablesToExport    = @('')

    PrivateData          = @{
        PSData = @{
            Tags         = @('performance', 'lint', 'ci')

            LicenseUri   = ''

            ProjectUri   = ''

            IconUri      = ''

            ReleaseNotes = @'
'@
        }
    }

    # HelpInfoURI = ''
}
