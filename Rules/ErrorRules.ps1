class CheckForUndefinedVariables : ErrorRule {
    CheckForUndefinedVariables() : base('CheckForUndefinedVariables', 'Check for undefined variables') {}

    [object]Invoke([System.Management.Automation.Language.Ast]$ast) {
    }
}
