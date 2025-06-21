function pslint {
    <#
    .SYNOPSIS
    Performance-focused PowerShell linter for analyzing scripts.

    .DESCRIPTION
    Analyzes a PowerShell script for performance issues. Supports PowerShell Core and Windows PowerShell.

    .PARAMETER Path
    The path to the script to analyze.

    .PARAMETER ScriptBlock
    The script block to analyze.

    .EXAMPLE
    Analyze a file:
    pslint -Path ".\your-script.ps1"

    Analyze a script block:
    $sb = { Write-Host "test" }
    pslint -ScriptBlock $sb

    .NOTES
            Author		: @Calvindd2f
            Site		: https://app-support.com
            File Name	: pslint
            Version     : 1.0
    #>
    [Alias('Scan-PowerShellScriptAdvanced')]
    [CmdletBinding()]
    PARAM (
        [Parameter(ParameterSetName = 'Path')]
        [ValidateScript({ $_ -match '\.ps1$' })]
        [string]
        $Path,

        [Parameter(ParameterSetName = 'ScriptBlock')]
        [scriptblock]
        $ScriptBlock
    )

    BEGIN {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            if (-not (Test-Path $Path)) {
                throw "File not found: $Path"
            }
            $parseErrors = $null
            $tokens = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$parseErrors)

            if ($parseErrors) {
                throw "Parse errors encountered: $($parseErrors -join "`n")"
            }
        }
        else {
            if ($null -eq $ScriptBlock) {
                throw 'ScriptBlock cannot be null'
            }
            $ast = $ScriptBlock.Ast
        }

        class CodeAnalysisResults {
            [System.Collections.Generic.List[object]]$OutputSuppression = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$ArrayAddition = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$StringAddition = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$LargeFileProcessing = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$LargeCollectionLookup = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$WriteHostUsage = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$LargeLoops = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$RepeatedFunctionCalls = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$CmdletPipelineWrapping = [System.Collections.Generic.List[object]]::new()
            [System.Collections.Generic.List[object]]$DynamicObjectCreation = [System.Collections.Generic.List[object]]::new()

            [void] ClearLists() {
                $this.OutputSuppression.Clear()
                $this.ArrayAddition.Clear()
                $this.StringAddition.Clear()
                $this.LargeFileProcessing.Clear()
                $this.LargeCollectionLookup.Clear()
                $this.WriteHostUsage.Clear()
                $this.LargeLoops.Clear()
                $this.RepeatedFunctionCalls.Clear()
                $this.CmdletPipelineWrapping.Clear()
                $this.DynamicObjectCreation.Clear()
            }
        }

        class ScriptAnalyzerVisitor : System.Management.Automation.Language.AstVisitor2 {
            [CodeAnalysisResults]$Results

            ScriptAnalyzerVisitor() {
                $this.Results = [CodeAnalysisResults]::new()
            }

            #region Visit Methods
            [System.Management.Automation.Language.AstVisitAction] VisitAssignmentStatement([System.Management.Automation.Language.AssignmentStatementAst] $assignmentStatementAst) {
                # Output Suppression: $null assignment
                if ($null -ne $assignmentStatementAst.Right -and
                    $assignmentStatementAst.Right -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $assignmentStatementAst.Right.VariablePath.UserPath -eq 'null') {
                    $this.Results.OutputSuppression.Add($assignmentStatementAst)
                }

                # Array Addition: $array = @()
                if ($assignmentStatementAst.Operator -eq 'Equals' -and
                    $null -ne $assignmentStatementAst.Right -and
                    $assignmentStatementAst.Right -is [System.Management.Automation.Language.ArrayExpressionAst]) {
                    # This is a weak check and can lead to false positives.
                    # To reduce noise, we only flag the use of += on arrays.
                }

                # Array/String Addition: +=
                if ($assignmentStatementAst.Operator -eq 'PlusEquals') {
                    # Avoid flagging numeric operations
                    if ($assignmentStatementAst.Right -isnot [System.Management.Automation.Language.ConstantExpressionAst] -or
                        ($assignmentStatementAst.Right -is [System.Management.Automation.Language.ConstantExpressionAst] -and $assignmentStatementAst.Right.Value -isnot [int] -and $assignmentStatementAst.Right.Value -isnot [double] -and $assignmentStatementAst.Right.Value -isnot [decimal])) {
                        $this.Results.ArrayAddition.Add($assignmentStatementAst)
                        $this.Results.StringAddition.Add($assignmentStatementAst)
                    }
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitCommand([System.Management.Automation.Language.CommandAst] $commandAst) {
                # Output Suppression: > $null
                if ($commandAst.Redirections.Count -gt 0 -and
                    $null -ne $commandAst.Redirections[0] -and
                    $commandAst.Redirections[0].ToString() -eq ">$null") {
                    $this.Results.OutputSuppression.Add($commandAst)
                }

                if ($commandAst.CommandElements.Count -gt 0) {
                    $commandName = $commandAst.CommandElements[0].ToString()
                    switch -Wildcard ($commandName) {
                        'Get-Content' { $this.Results.LargeFileProcessing.Add($commandAst) }
                        'Write-Host' { $this.Results.WriteHostUsage.Add($commandAst) }
                        'Add-Member' { $this.Results.DynamicObjectCreation.Add($commandAst) }
                        'Get-WmiObject' { $this.Results.CmdletPipelineWrapping.Add($commandAst) }
                    }
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitCommandExpression([System.Management.Automation.Language.CommandExpressionAst] $commandExpressionAst) {
                # Output Suppression: [void]
                if ($null -ne $commandExpressionAst.Expression -and
                    $commandExpressionAst.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                    $commandExpressionAst.Expression.TypeName.Name -eq 'void') {
                    $this.Results.OutputSuppression.Add($commandExpressionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitPipeline([System.Management.Automation.Language.PipelineAst] $pipelineAst) {
                # Output Suppression: | Out-Null
                if ($pipelineAst.PipelineElements.Count -gt 0 -and
                    $null -ne $pipelineAst.PipelineElements[-1].CommandElements -and
                    $pipelineAst.PipelineElements[-1].CommandElements.Count -gt 0 -and
                    $pipelineAst.PipelineElements[-1].CommandElements[-1].Value -eq 'Out-Null') {
                    $this.Results.OutputSuppression.Add($pipelineAst)
                }

                # Cmdlet Pipeline Wrapping
                if ($pipelineAst.PipelineElements.Count -gt 2) {
                    $this.Results.CmdletPipelineWrapping.Add($pipelineAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitInvokeMemberExpression([System.Management.Automation.Language.InvokeMemberExpressionAst] $invokeMemberExpressionAst) {
                if ($null -ne $invokeMemberExpressionAst.Member) {
                    $memberName = $invokeMemberExpressionAst.Member.Value
                    if ($memberName -eq 'Add') {
                        $this.Results.ArrayAddition.Add($invokeMemberExpressionAst)
                    }
                    elseif ($memberName -eq 'ReadLines' -and $invokeMemberExpressionAst.Expression.TypeName.Name -eq 'File') {
                        $this.Results.LargeFileProcessing.Add($invokeMemberExpressionAst)
                    }
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitBinaryExpression([System.Management.Automation.Language.BinaryExpressionAst] $binaryExpressionAst) {
                # String Addition: -f or +
                if ($binaryExpressionAst.Operator -eq 'Format' -or
                    ($binaryExpressionAst.Operator -eq 'Plus' -and ($binaryExpressionAst.Left -is [System.Management.Automation.Language.StringConstantExpressionAst] -or $binaryExpressionAst.Right -is [System.Management.Automation.Language.StringConstantExpressionAst]))) {
                    $this.Results.StringAddition.Add($binaryExpressionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitExpandableStringExpression([System.Management.Automation.Language.ExpandableStringExpressionAst] $expandableStringExpressionAst) {
                # String Addition: "$()"
                if ($expandableStringExpressionAst.NestedExpressions.Count -gt 0) {
                    $this.Results.StringAddition.Add($expandableStringExpressionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitTypeExpression([System.Management.Automation.Language.TypeExpressionAst] $typeExpressionAst) {
                # Large File Processing: [StreamReader]
                if ($typeExpressionAst.TypeName.Name -eq 'StreamReader') {
                    $this.Results.LargeFileProcessing.Add($typeExpressionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitHashtable([System.Management.Automation.Language.HashtableAst] $hashtableAst) {
                if ($hashtableAst.KeyValuePairs.Count -gt 10) {
                    $this.Results.LargeCollectionLookup.Add($hashtableAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitForStatement([System.Management.Automation.Language.ForStatementAst] $forStatementAst) {
                if ($forStatementAst.Body.Extent.EndLineNumber - $forStatementAst.Body.Extent.StartLineNumber > 15) {
                    $this.Results.LargeLoops.Add($forStatementAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitWhileStatement([System.Management.Automation.Language.WhileStatementAst] $whileStatementAst) {
                if ($whileStatementAst.Body.Extent.EndLineNumber - $whileStatementAst.Body.Extent.StartLineNumber > 15) {
                    $this.Results.LargeLoops.Add($whileStatementAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitDoWhileStatement([System.Management.Automation.Language.DoWhileStatementAst] $doWhileStatementAst) {
                if ($doWhileStatementAst.Body.Extent.EndLineNumber - $doWhileStatementAst.Body.Extent.StartLineNumber > 15) {
                    $this.Results.LargeLoops.Add($doWhileStatementAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitForEachStatement([System.Management.Automation.Language.ForEachStatementAst] $forEachStatementAst) {
                if ($forEachStatementAst.Body.Extent.EndLineNumber - $forEachStatementAst.Body.Extent.StartLineNumber > 15) {
                    $this.Results.LargeLoops.Add($forEachStatementAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitFunctionDefinition([System.Management.Automation.Language.FunctionDefinitionAst] $functionDefinitionAst) {
                if ($functionDefinitionAst.Body.Extent.Text -match 'for\s*\(') {
                    $this.Results.RepeatedFunctionCalls.Add($functionDefinitionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitConvertExpression([System.Management.Automation.Language.ConvertExpressionAst] $convertExpressionAst) {
                if ($convertExpressionAst.Type.TypeName.Name -eq 'pscustomobject') {
                    $this.Results.DynamicObjectCreation.Add($convertExpressionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }

            [System.Management.Automation.Language.AstVisitAction] VisitMemberExpression([System.Management.Automation.Language.MemberExpressionAst] $memberExpressionAst) {
                if ($memberExpressionAst.Member.Value -eq 'Properties' -and $memberExpressionAst.Expression.TypeName.Name -eq 'PSObject') {
                    $this.Results.DynamicObjectCreation.Add($memberExpressionAst)
                }
                return [System.Management.Automation.Language.AstVisitAction]::Continue
            }
            #endregion
        }
    }

    PROCESS {
        $visitor = [ScriptAnalyzerVisitor]::new()
        $ast.Visit($visitor)
        $results = $visitor.Results
    }

    END {
        $report = [PslintLib.Analysis.ReportGenerator]::Generate($results, $Path, [bool]$env:CI)
        return $report
    }
}