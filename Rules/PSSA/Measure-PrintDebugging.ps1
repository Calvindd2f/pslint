using namespace System.Management.Automation.Language;
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic;

# Rule to check for print debugging in functions
function Measure-PrintDebugging
{
    [CmdletBinding()]
    [OutputType([DiagnosticRecord[]])]
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ScriptBlockAst]
        $ScriptBlockAst
    )

    Process
    {
        $results = @()

        $ScriptBlockAst.FindAll({
                param($ast)
                $ast -is [FunctionDefinitionAst]
            }, $true) | ForEach-Object {
            $function = $_
            $debugStatements = $function.Body.FindAll({
                    param($ast)
                    $ast -is [CommandAst] -and $ast.GetCommandName() -in @('Write-Host', 'Write-Debug', 'Write-Verbose')
                }, $true)

            if (-not $debugStatements)
            {
                $results += [DiagnosticRecord]@{
                    Message  = "Function '$($function.Name)' does not have print debugging statements"
                    Extent   = $function.Extent
                    RuleName = $MyInvocation.MyCommand.Name
                    Severity = 'Information'
                }
            }
        }

        return $results
    }
}

Export-ModuleMember -Function @('Measure-PrintDebugging')