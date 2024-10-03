function pslint
{
    <#
        .SYNOPSIS
        Performance focused powershell linteer.

        .DESCRIPTION
        Analyzes a PowerShell script for performance issues.
        Built on and for PowerShell Core.
        Support for Windows PowerShell is currently still active, but is not prioritized.
        It will be announced when support is dropped, it will stop being tested before push afterwards. This does not explicitly mean it will not work.
        It just means I am under no obligation to answer, action, humour or keep open Issues and Requests relating to the linter on Windows PowerShell a.k.a powershell.exe

        .PARAMETER Path
        The path to the script to analyze.

        .PARAMETER ScriptBlock
        The script block to analyze.

        .PARAMETER Debug
        Enables debug output.

        .PARAMETER Output
        The path to the output file.

        .EXAMPLE
        pslint -Path C:\path\to\script.ps1

        .NOTES
        General notes
        #read_only
        ####################################################
        ##########  INPUT
        #####################################################
        ####################################################
        ##########  OUTPUT
        #####################################################
        $variableProps = @{}
        $outputProps = @{ out = [psobject]($variableProps); success = $false; }
        $pslintOutput = [psobject]($outputProps);
        #/read_only
    #>
    [Alias('Scan-PowerShellScriptAdvanced')]
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Path')]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ScriptBlock')]
        [scriptblock]
        $ScriptBlock,

        [Parameter(DontShow = $true)]
        [switch]
        $Debug,

        [Parameter]
        [string]
        $Output = [datetime]::Now.ToString('o') + 'pslint_output.log'
    )
    BEGIN
    {
        if ($PSCmdlet.ParameterSetName -eq 'Path')
        {
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null)
        }
        else
        {
            $ast = $ScriptBlock.Ast
        }

        class CodeAnalysisResults
        {
            [System.Collections.Generic.List[object]]$OutputSuppression
            [System.Collections.Generic.List[object]]$ArrayAddition
            [System.Collections.Generic.List[object]]$LargeFileProcessing
            [System.Collections.Generic.List[object]]$LargeCollectionLookup
            [System.Collections.Generic.List[object]]$WriteHostUsage
            [System.Collections.Generic.List[object]]$LargeLoops
            [System.Collections.Generic.List[object]]$RepeatedFunctionCalls
            [System.Collections.Generic.List[object]]$CmdletPipelineWrapping
            [System.Collections.Generic.List[object]]$DynamicObjectCreation

            CodeAnalysisResults()
            {
                $this.OutputSuppression = [System.Collections.Generic.List[object]]::new()
                $this.ArrayAddition = [System.Collections.Generic.List[object]]::new()
                $this.LargeFileProcessing = [System.Collections.Generic.List[object]]::new()
                $this.LargeCollectionLookup = [System.Collections.Generic.List[object]]::new()
                $this.WriteHostUsage = [System.Collections.Generic.List[object]]::new()
                $this.LargeLoops = [System.Collections.Generic.List[object]]::new()
                $this.RepeatedFunctionCalls = [System.Collections.Generic.List[object]]::new()
                $this.CmdletPipelineWrapping = [System.Collections.Generic.List[object]]::new()
                $this.DynamicObjectCreation = [System.Collections.Generic.List[object]]::new()
            }
        }
        $variableProps = @{ result = $null; }
        $outputProps = @{ out = [psobject]($variableProps); success = $false; error = $null; }
        $pslintOutput = [psobject]($outputProps);
    }
    PROCESS
    {
        $results = [CodeAnalysisResults]::new();

        # Output Suppression
        $ast.FindAll({
                param($node)
        ($node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $node.Right -is [System.Management.Automation.Language.VariableExpressionAst] -and
                $node.Right.VariablePath.UserPath -eq 'null') -or
        ($node -is [System.Management.Automation.Language.CommandAst] -and
                $node.Redirections.Count -gt 0 -and
                $node.Redirections[0].ToString() -eq ">$null") -or
        ($node -is [System.Management.Automation.Language.CommandExpressionAst] -and
                $node.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                $node.Expression.TypeName.Name -eq 'void') -or
        ($node -is [System.Management.Automation.Language.PipelineAst] -and
                $node.PipelineElements[-1].CommandElements[-1].Value -eq 'Out-Null')
            }, $true) | ForEach-Object { $results.OutputSuppression.Add($_) }

        # ArrayAddition
        $ast.FindAll({
                param($node)
        ($node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $node.Operator -eq 'Equals' -and
                $node.Right -is [System.Management.Automation.Language.ArrayExpressionAst]) -or
        ($node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                $node.Member.Value -eq 'Add') -or
        ($node -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $node.Operator -eq 'PlusEquals')
            }, $true) | ForEach-Object { $results.ArrayAddition.Add($_) }

        # String Addition

        # Large File Processing
        $ast.FindAll({
                param($node)
        ($node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq 'Get-Content') -or
        ($node -is [System.Management.Automation.Language.TypeExpressionAst] -and
                $node.TypeName.Name -eq 'StreamReader') -or
        ($node -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                $node.Expression.TypeName.Name -eq 'File' -and
                $node.Member.Value -eq 'ReadLines')
            }, $true) | ForEach-Object { $results.LargeFileProcessing.Add($_) }

        # Large Collection Lookup
        $ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.HashtableAst]
            }, $true) | ForEach-Object { $results.LargeCollectionLookup.Add($_) }

        # Write-Host Usage
        $ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq 'Write-Host'
            }, $true) | ForEach-Object { $results.WriteHostUsage.Add($_) }

        # Large Loops (potential JIT candidates)
        $ast.FindAll({
                param($node)
        ($node -is [System.Management.Automation.Language.ForStatementAst] -or
                $node -is [System.Management.Automation.Language.WhileStatementAst] -or
                $node -is [System.Management.Automation.Language.DoWhileStatementAst] -or
                $node -is [System.Management.Automation.Language.ForEachStatementAst]) -and
                $node.Body.Extent.EndLineNumber - $node.Body.Extent.StartLineNumber > 15
            }, $true) | ForEach-Object { $results.LargeLoops.Add($_) }

        # Repeated Function Calls
        $ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                $node.Body.Extent.Text -match 'for\s*\('
            }, $true) | ForEach-Object { $results.OutputSuppression.Add($_) }

        # Cmdlet Pipeline Wrapping
        $ast.FindAll({
                param($node)
                $node -is [System.Management.Automation.Language.PipelineAst] -and
                $node.PipelineElements.Count -gt 2
            }, $true) | ForEach-Object { $results.OutputSuppression.Add($_) }

        # Dynamic Object Creation
        $ast.FindAll({
                param($node)
        ($node -is [System.Management.Automation.Language.ConvertExpressionAst] -and
                $node.Type.TypeName.Name -eq 'pscustomobject') -or
        ($node -is [System.Management.Automation.Language.CommandAst] -and
                $node.CommandElements[0].Value -eq 'Add-Member') -or
        ($node -is [System.Management.Automation.Language.MemberExpressionAst] -and
                $node.Member.Value -eq 'Properties' -and
                $node.Expression.TypeName.Name -eq 'PSObject')
            }, $true) | ForEach-Object { $results.OutputSuppression.Add($_) }

        $pslintOutput.out.result += $result;
        $pslintOutput.success = $true;
    }

    END
    {
        if (!$pslintOutput.success)
        {
            $pslintOutput.success = $false;
            $errorMessages = @($_.ErrorDetails.Message)
            $pslintOutput.error += $errorMessages
        }

        # Garbage collection
        [GC]::WaitForPendingFinalizers()
        [GC]::Collect()

        return $pslintOutput
    }
}
