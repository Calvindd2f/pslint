function Get-RuleSet {
    # Define the rule set
    $ruleSet = @(
        [PerformanceRule]::new('AvoidUsingWriteHost', 'Avoid using Write-Host')
        [ErrorRule]::new('CheckForUndefinedVariables', 'Check for undefined variables')
    )

    $ruleSet
}

class PerformanceRule {
    [string]$Name
    [string]$Description

    PerformanceRule([string]$Name, [string]$Description) {
        $this.Name = $Name
        $this.Description = $Description
    }

    [object]Invoke([System.Management.Automation.Language.Ast]$ast) {
    }
}

class ErrorRule {
    [string]$Name
    [string]$Description

    ErrorRule([string]$Name, [string]$Description) {
        $this.Name = $Name
        $this.Description = $Description
    }

    [object]Invoke([System.Management.Automation.Language.Ast]$ast) {
    }
}
