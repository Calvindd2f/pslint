@ {
    # Severity-filter doesn't affect custom rules (always considered Warning) in PSSA 1.x
    Severity            = @('Error', 'Warning')
    IncludeDefaultRules = $true
    ExcludeRules        = @(
        'PSUseShouldProcessForStateChangingFunctions'
        'PSUseApprovedVerbs'
        '*Manifest*' # Throws error due to missing PesterConfiguration.Format.ps1xml
    )
}