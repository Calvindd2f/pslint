@{
    RootModule           = 'pslint.psm1'

    Author               = 'Calvin Bergin <Calvindd2f>'

    CompanyName          = 'Calvindd2f'

    ModuleVersion        = '2.0.0'

    GUID                 = 'bc931fbd-b205-45be-9ecf-4f9db144998b'

    Copyright            = '2025 Calvindd2f'

    Description          = 'Performance focused linter for PowerShell scripts and Modules'

    PowerShellVersion    = '5.1.0'

    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport    = @('pslint') # Also ensure all three entries are present

    AliasesToExport      = @('Scan-PowerShellScriptAdvanced')

    VariablesToExport    = @()  # Specify an empty array, not $null

    CmdletsToExport      = @()  #  A missing or $null entry is equivalent to specifying the wildcard *

    PrivateData          = @{
        PSData = @{
            Tags         = @('Performance', 'lint', 'Memory Optimized', 'Non-Idiomatic', 'Elitism', 'Workflow Safe')

            LicenseUri   = 'https://opensource.org/license/mit'

            ProjectUri   = 'https://github.com/calvindd2f/pslint'

            IconUri      = 'https://app-support.com/public/img/plint.webp'

            ReleaseNotes = 'Initial push to PSGallery'
        }
    }

    HelpInfoURI          = 'https://app-support.com/'
}
