using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public class ScriptAnalyzerVisitor : AstVisitor2
{
    public CodeAnalysisResults Results { get; } = new();

    public override AstVisitAction VisitAssignmentStatement(AssignmentStatementAst assignmentStatementAst)
    {
        // Output Suppression: $null assignment
        if (assignmentStatementAst.Right is CommandExpressionAst cmdExpr &&
            cmdExpr.Expression is VariableExpressionAst rightVar &&
            rightVar.VariablePath.UserPath == "null")
        {
            Results.OutputSuppression.Add(assignmentStatementAst);
        }

        // Array Addition: $array = @()
        // Note: original script only flagged usage of += on arrays.

        // Array/String Addition: +=
        if (assignmentStatementAst.Operator == TokenKind.PlusEquals)
        {
            if (assignmentStatementAst.Right is CommandExpressionAst ceAst && ceAst.Expression is ConstantExpressionAst constAst)
            {
                if (constAst.Value is int || constAst.Value is double || constAst.Value is decimal)
                {
                    // numeric operations are ignored
                }
                else
                {
                    Results.ArrayAddition.Add(assignmentStatementAst);
                    Results.StringAddition.Add(assignmentStatementAst);
                }
            }
            else
            {
                Results.ArrayAddition.Add(assignmentStatementAst);
                Results.StringAddition.Add(assignmentStatementAst);
            }
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommand(CommandAst commandAst)
    {
        // Output Suppression: > $null
        if (commandAst.Redirections.Count > 0 &&
            commandAst.Redirections[0] != null &&
            commandAst.Redirections[0].ToString() == ">$null")
        {
            Results.OutputSuppression.Add(commandAst);
        }

        if (commandAst.CommandElements.Count > 0)
        {
            var commandName = commandAst.CommandElements[0].ToString();
            if (string.Equals(commandName, "Get-Content", StringComparison.OrdinalIgnoreCase))
            {
                Results.LargeFileProcessing.Add(commandAst);
            }
            else if (string.Equals(commandName, "Write-Host", StringComparison.OrdinalIgnoreCase))
            {
                Results.WriteHostUsage.Add(commandAst);
            }
            else if (string.Equals(commandName, "Add-Member", StringComparison.OrdinalIgnoreCase))
            {
                Results.DynamicObjectCreation.Add(commandAst);
            }
            else if (string.Equals(commandName, "Get-WmiObject", StringComparison.OrdinalIgnoreCase))
            {
                Results.CmdletPipelineWrapping.Add(commandAst);
            }
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommandExpression(CommandExpressionAst commandExpressionAst)
    {
        // Output Suppression: [void]
        if (commandExpressionAst.Expression is TypeExpressionAst typeExpr &&
            string.Equals(typeExpr.TypeName.Name, "void", StringComparison.OrdinalIgnoreCase))
        {
            Results.OutputSuppression.Add(commandExpressionAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitPipeline(PipelineAst pipelineAst)
    {
        // Output Suppression: | Out-Null
        if (pipelineAst.PipelineElements.Count > 0)
        {
            if (pipelineAst.PipelineElements[^1] is CommandAst lastCmd &&
                lastCmd.CommandElements.Count > 0 &&
                lastCmd.CommandElements[^1] is StringConstantExpressionAst lastElement &&
                string.Equals(lastElement.Value, "Out-Null", StringComparison.OrdinalIgnoreCase))
            {
                Results.OutputSuppression.Add(pipelineAst);
            }
        }

        // Cmdlet Pipeline Wrapping
        if (pipelineAst.PipelineElements.Count > 2)
        {
            Results.CmdletPipelineWrapping.Add(pipelineAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitInvokeMemberExpression(InvokeMemberExpressionAst invokeMemberExpressionAst)
    {
        if (invokeMemberExpressionAst.Member is StringConstantExpressionAst member)
        {
            var memberName = member.Value;
            if (memberName == "Add")
            {
                Results.ArrayAddition.Add(invokeMemberExpressionAst);
            }
            else if (memberName == "ReadLines" && invokeMemberExpressionAst.Expression is TypeExpressionAst typeExpr &&
                     typeExpr.TypeName.Name == "File")
            {
                Results.LargeFileProcessing.Add(invokeMemberExpressionAst);
            }
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitBinaryExpression(BinaryExpressionAst binaryExpressionAst)
    {
        // String Addition: -f or +
        if (binaryExpressionAst.Operator == TokenKind.Format ||
            (binaryExpressionAst.Operator == TokenKind.Plus &&
             (binaryExpressionAst.Left is StringConstantExpressionAst ||
              binaryExpressionAst.Right is StringConstantExpressionAst)))
        {
            Results.StringAddition.Add(binaryExpressionAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitExpandableStringExpression(ExpandableStringExpressionAst expandableStringExpressionAst)
    {
        // String Addition: "$()"
        if (expandableStringExpressionAst.NestedExpressions.Count > 0)
        {
            Results.StringAddition.Add(expandableStringExpressionAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitTypeExpression(TypeExpressionAst typeExpressionAst)
    {
        // Large File Processing: [StreamReader]
        if (string.Equals(typeExpressionAst.TypeName.Name, "StreamReader", StringComparison.OrdinalIgnoreCase))
        {
            Results.LargeFileProcessing.Add(typeExpressionAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitHashtable(HashtableAst hashtableAst)
    {
        if (hashtableAst.KeyValuePairs.Count > 10)
        {
            Results.LargeCollectionLookup.Add(hashtableAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitForStatement(ForStatementAst forStatementAst)
    {
        if (forStatementAst.Body.Extent.EndLineNumber - forStatementAst.Body.Extent.StartLineNumber > 15)
        {
            Results.LargeLoops.Add(forStatementAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitWhileStatement(WhileStatementAst whileStatementAst)
    {
        if (whileStatementAst.Body.Extent.EndLineNumber - whileStatementAst.Body.Extent.StartLineNumber > 15)
        {
            Results.LargeLoops.Add(whileStatementAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitDoWhileStatement(DoWhileStatementAst doWhileStatementAst)
    {
        if (doWhileStatementAst.Body.Extent.EndLineNumber - doWhileStatementAst.Body.Extent.StartLineNumber > 15)
        {
            Results.LargeLoops.Add(doWhileStatementAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitForEachStatement(ForEachStatementAst forEachStatementAst)
    {
        if (forEachStatementAst.Body.Extent.EndLineNumber - forEachStatementAst.Body.Extent.StartLineNumber > 15)
        {
            Results.LargeLoops.Add(forEachStatementAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitFunctionDefinition(FunctionDefinitionAst functionDefinitionAst)
    {
        if (System.Text.RegularExpressions.Regex.IsMatch(functionDefinitionAst.Body.Extent.Text, @"for\s*\(", System.Text.RegularExpressions.RegexOptions.IgnoreCase))
        {
            Results.RepeatedFunctionCalls.Add(functionDefinitionAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitConvertExpression(ConvertExpressionAst convertExpressionAst)
    {
        if (string.Equals(convertExpressionAst.Type.TypeName.Name, "pscustomobject", StringComparison.OrdinalIgnoreCase))
        {
            Results.DynamicObjectCreation.Add(convertExpressionAst);
        }

        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitMemberExpression(MemberExpressionAst memberExpressionAst)
    {
        if (memberExpressionAst.Member is StringConstantExpressionAst member &&
            member.Value == "Properties" &&
            memberExpressionAst.Expression is TypeExpressionAst typeExpr &&
            typeExpr.TypeName.Name == "PSObject")
        {
            Results.DynamicObjectCreation.Add(memberExpressionAst);
        }

        return AstVisitAction.Continue;
    }
}
