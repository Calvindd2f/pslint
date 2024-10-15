function pslint
{
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

    BEGIN
    {
        if ($PSCmdlet.ParameterSetName -eq 'Path')
        {
            if (-not (Test-Path $Path))
            {
                throw "File not found: $Path"
            }
            $parseErrors = $null
            $tokens = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$parseErrors)

            if ($parseErrors)
            {
                throw "Parse errors encountered: $($parseErrors -join "`n")"
            }
        }
        else
        {
            if ($null -eq $ScriptBlock)
            {
                throw 'ScriptBlock cannot be null'
            }
            $ast = $ScriptBlock.Ast
        }

        class CodeAnalysisResults
        {
            [System.Collections.Generic.List[object]]$OutputSuppression
            [System.Collections.Generic.List[object]]$ArrayAddition
            [System.Collections.Generic.List[object]]$LargeFileProcessing
            [System.Collections.Generic.List[object]]$LargeCollectionLookup
            [System.Collections.Generic.List[object]]$WriteVerboseUsage
            [System.Collections.Generic.List[object]]$LargeLoops
            [System.Collections.Generic.List[object]]$RepeatedFunctionCalls
            [System.Collections.Generic.List[object]]$CmdletPipelineWrapping
            [System.Collections.Generic.List[object]]$DynamicObjectCreation

            CodeAnalysisResults()
            {
                $this.OutputSuppression = $this.InitializeList()
                $this.ArrayAddition = $this.InitializeList()
                $this.LargeFileProcessing = $this.InitializeList()
                $this.LargeCollectionLookup = $this.InitializeList()
                $this.WriteVerboseUsage = $this.InitializeList()
                $this.LargeLoops = $this.InitializeList()
                $this.RepeatedFunctionCalls = $this.InitializeList()
                $this.CmdletPipelineWrapping = $this.InitializeList()
                $this.DynamicObjectCreation = $this.InitializeList()
            }

            [System.Collections.Generic.List[object]] InitializeList()
            {
                return [System.Collections.Generic.List[object]]::new()
            }

            [void] ClearLists()
            {
                $this.OutputSuppression.Clear()
                $this.ArrayAddition.Clear()
                $this.LargeFileProcessing.Clear()
                $this.LargeCollectionLookup.Clear()
                $this.WriteVerboseUsage.Clear()
                $this.LargeLoops.Clear()
                $this.RepeatedFunctionCalls.Clear()
                $this.CmdletPipelineWrapping.Clear()
                $this.DynamicObjectCreation.Clear()
            }
        }
    }

    PROCESS
    {
        $results = [CodeAnalysisResults]::new()

        function Test-NodeSafely
        {
            param(
                [Parameter(Mandatory)]
                [System.Management.Automation.Language.Ast]$Node,
                [Parameter(Mandatory)]
                [scriptblock]$Condition
            )

            try
            {
                return (& $Condition $Node)
            }
            catch
            {
                Write-Verbose "Error checking node: $_"
                return $false
            }
        }

        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                ($n -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $null -ne $n.Right -and
                    $n.Right -is [System.Management.Automation.Language.VariableExpressionAst] -and
                    $n.Right.VariablePath.UserPath -eq 'null') -or
                ($n -is [System.Management.Automation.Language.CommandAst] -and
                    $n.Redirections.Count -gt 0 -and
                    $null -ne $n.Redirections[0] -and
                    $n.Redirections[0].ToString() -eq ">$null") -or
                ($n -is [System.Management.Automation.Language.CommandExpressionAst] -and
                    $null -ne $n.Expression -and
                    $n.Expression -is [System.Management.Automation.Language.TypeExpressionAst] -and
                    $n.Expression.TypeName.Name -eq 'void') -or
                ($n -is [System.Management.Automation.Language.PipelineAst] -and
                    $n.PipelineElements.Count -gt 0 -and
                    $null -ne $n.PipelineElements[-1].CommandElements -and
                    $n.PipelineElements[-1].CommandElements.Count -gt 0 -and
                    $n.PipelineElements[-1].CommandElements[-1].Value -eq 'Out-Null')
                }
            }, $true) | Where-Object { $null -ne $_ } | ForEach-Object { $results.OutputSuppression.Add($_) }

        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                ($n -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $n.Operator -eq 'Equals' -and
                    $null -ne $n.Right -and
                    $n.Right -is [System.Management.Automation.Language.ArrayExpressionAst]) -or
                ($n -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                    $null -ne $n.Member -and
                    $n.Member.Value -eq 'Add') -or
                ($n -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $n.Operator -eq 'PlusEquals')
                }
            }, $true) | Where-Object { $null -ne $_ } | ForEach-Object { $results.ArrayAddition.Add($_) }

        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                ($n -is [System.Management.Automation.Language.CommandAst] -and
                    $n.CommandElements[0].Value -eq 'Get-Content') -or
                ($n -is [System.Management.Automation.Language.TypeExpressionAst] -and
                    $n.TypeName.Name -eq 'StreamReader') -or
                ($n -is [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                    $n.Expression.TypeName.Name -eq 'File' -and
                    $n.Member.Value -eq 'ReadLines')
                }
            }, $true) | ForEach-Object { $results.LargeFileProcessing.Add($_) }

        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                    $n -is [System.Management.Automation.Language.HashtableAst]
                }
            }, $true) | ForEach-Object { $results.LargeCollectionLookup.Add($_) }


        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                    $n -is [System.Management.Automation.Language.CommandAst] -and
                    $n.CommandElements[0].Value -eq 'Write-Host'
                }
            }, $true) | ForEach-Object { $results.WriteHostUsage.Add($_) }


        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                ($n -is [System.Management.Automation.Language.ForStatementAst] -or
                    $n -is [System.Management.Automation.Language.WhileStatementAst] -or
                    $n -is [System.Management.Automation.Language.DoWhileStatementAst] -or
                    $n -is [System.Management.Automation.Language.ForEachStatementAst]) -and
                    $node.Body.Extent.EndLineNumber - $node.Body.Extent.StartLineNumber > 15
                }
            }, $true) | ForEach-Object { $results.LargeLoops.Add($_) }


        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                    $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                    $n.Body.Extent.Text -match 'for\s*\('
                }
            }, $true) | ForEach-Object { $results.RepeatedFunctionCalls.Add($_) }


        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                    $n -is [System.Management.Automation.Language.PipelineAst] -and
                    $n.PipelineElements.Count -gt 2
                }
            }, $true) | ForEach-Object { $results.CmdletPipelineWrapping.Add($_) }


        $ast.FindAll({
                param($node)
                Test-NodeSafely -Node $node -Condition {
                    param($n)
                ($n -is [System.Management.Automation.Language.ConvertExpressionAst] -and
                    $n.Type.TypeName.Name -eq 'pscustomobject') -or
                ($n -is [System.Management.Automation.Language.CommandAst] -and
                    $n.CommandElements[0].Value -eq 'Add-Member') -or
                ($n -is [System.Management.Automation.Language.MemberExpressionAst] -and
                    $n.Member.Value -eq 'Properties' -and
                    $n.Expression.TypeName.Name -eq 'PSObject')
                }
            }, $true) | ForEach-Object { $results.DynamicObjectCreation.Add($_) }
    }

    END
    {
        $report = [ordered]@{
            Summary    = @{
                TotalIssues = 0
                Categories  = @{}
            }
            Details    = [ordered]@{}
            Timestamp  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ScriptPath = if ($Path) { $Path } else { "ScriptBlock Analysis" }
        }

        $results | Get-Member -MemberType Property | ForEach-Object {
            $categoryName = $_.Name
            $issues = $results.$categoryName

            if ($issues.Count -eq 0) { return }

            $report.Summary.Categories[$categoryName] = $issues.Count
            $report.Summary.TotalIssues += $issues.Count

            $report.Details[$categoryName] = @(
                foreach ($issue in $issues)
                {
                    @{
                        Line       = $issue.Extent.StartLineNumber
                        Text       = $issue.Extent.Text.Trim()
                        Suggestion = switch ($categoryName)
                        {
                            'OutputSuppression' { 'Consider using [void] for better performance' }
                            'ArrayAddition' { 'Consider using ArrayList or Generic List for better performance' }
                            'LargeFileProcessing' { 'Consider using System.IO.StreamReader for large files' }
                            'LargeCollectionLookup' { 'Consider using Dictionary<TKey,TValue> for large collections' }
                            'WriteHostUsage' { "Consider using Write-Information, Write-Output or if you are a real CHAD - [console]::writeline(`$message)" }
                            'LargeLoops' { 'Consider breaking down large loops or using .NET methods' }
                            'RepeatedFunctionCalls' { 'Consider caching function results' }
                            'CmdletPipelineWrapping' { 'Consider reducing pipeline complexity' }
                            'DynamicObjectCreation' { 'Consider using classes or structured objects' }
                            default { 'Review for potential optimization' }
                        }
                    }
                }
            )
        }

        $isCI = [bool]$env:CI
        if ($isCI)
        {
            foreach ($category in $report.Details.Keys)
            {
                foreach ($issue in $report.Details[$category])
                {
                    Write-Output "::warning file=$($report.ScriptPath),line=$($issue.Line)::[$category] $($issue.Suggestion)"
                }
            }

            $report.Summary | ConvertTo-Json -Depth 10
        }
        else
        {
            Write-Output "`n=== PowerShell Performance Analysis Report ==="
            Write-Output "Script: $($report.ScriptPath)"
            Write-Output "Time: $($report.Timestamp)"
            Write-Output "`nSummary:"
            Write-Output "Total Issues Found: $($report.Summary.TotalIssues)"

            foreach ($category in $report.Details.Keys)
            {
                $issueCount = $report.Summary.Categories[$category]
                if ($issueCount -gt 0)
                {
                    Write-Output "`n== $category ($issueCount issues) =="
                    foreach ($issue in $report.Details[$category])
                    {
                        Write-Output "  Line $($issue.Line):"
                        Write-Output "    Code: $($issue.Text)"
                        Write-Output "    Suggestion: $($issue.Suggestion)"
                    }
                }
            }
        }

        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}