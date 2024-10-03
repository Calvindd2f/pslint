using namespace System.Management.Automation.Language
using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic

# Rule to detect trailing whitespace
function Measure-TrailingWhitespace
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
                $ast -is [StringConstantExpressionAst] -and $ast.Extent.Text.TrimEnd() -ne $ast.Extent.Text
            }, $true) | ForEach-Object {
            $results += [DiagnosticRecord]@{
                Message  = 'Line contains trailing whitespace'
                Extent   = $_.Extent
                RuleName = $MyInvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }

        return $results
    }
}
Export-ModuleMember -Function @('Measure-TrailingWhitespace')