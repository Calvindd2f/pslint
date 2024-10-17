@{
    RootModule           = 'pslint.psm1'

    Author               = 'Calvin Bergin <Calvindd2f>'

    CompanyName          = 'Calvindd2f'

    ModuleVersion        = '1.0.0'

    GUID                 = 'bc931fbd-b205-45be-9ecf-4f9db144998b'

    Copyright            = '2024 Calvindd2f'

    Description          = 'Performance focused linter for PowerShell scripts and Modules'

    PowerShellVersion    = '5.1.0'

    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport    = @('pslint')

    AliasesToExport      = @('Scan-PowerShellScriptAdvanced')

    VariablesToExport    = @('')

    PrivateData          = @{
        PSData = @{
            Tags         = @('Performance', 'lint', 'Memory Optimized','Non-Idiomatic','Elitism','Workflow Safe')

            LicenseUri   = 'https://opensource.org/license/mit'

            ProjectUri   = 'https://github.com/calvindd2f/pslint'

            IconUri      = 'https://app-support.com/public/img/plint.webp'

            ReleaseNotes = 'Initial push to PSGallery'
        }
    }

    HelpInfoURI          = 'https://app-support.com/'
}
