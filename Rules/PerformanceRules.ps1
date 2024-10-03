class AvoidUsingWriteHost : PerformanceRule {
   AvoidUsingWriteHost() : base('AvoidUsingWriteHost', 'Avoid using Write-Host') {}

   [object]Invoke([System.Management.Automation.Language.Ast]$ast) {
   }
}
