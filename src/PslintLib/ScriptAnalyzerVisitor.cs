using System.Management.Automation.Language;
using System.Text.RegularExpressions;

namespace PslintLib.Analysis;

public class ScriptAnalyzerVisitor : AstVisitor2
{
    public CodeAnalysisResults Results { get; } = new();

    public override AstVisitAction VisitAssignmentStatement(AssignmentStatementAst assignmentStatementAst)
    {
        if (assignmentStatementAst.Right is VariableExpressionAst varAst &&
            varAst.VariablePath.UserPath == "null")
        {
            Results.OutputSuppression.Add(assignmentStatementAst);
        }

        if (assignmentStatementAst.Operator == TokenKind.PlusEquals)
        {
            if (assignmentStatementAst.Right is not ConstantExpressionAst ce ||
                (ce.Value is not int && ce.Value is not double && ce.Value is not decimal))
            {
                Results.ArrayAddition.Add(assignmentStatementAst);
                Results.StringAddition.Add(assignmentStatementAst);
            }
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommand(CommandAst commandAst)
    {
        if (commandAst.Redirections.Count > 0 &&
            commandAst.Redirections[0]?.ToString() == ">$null")
        {
            Results.OutputSuppression.Add(commandAst);
        }

        if (commandAst.CommandElements.Count > 0)
        {
            var commandName = commandAst.CommandElements[0].ToString();
            if (WildcardPattern.Get("Get-Content", WildcardOptions.IgnoreCase).IsMatch(commandName))
            {
                Results.LargeFileProcessing.Add(commandAst);
            }
            else if (WildcardPattern.Get("Write-Host", WildcardOptions.IgnoreCase).IsMatch(commandName))
            {
                Results.WriteHostUsage.Add(commandAst);
            }
            else if (WildcardPattern.Get("Add-Member", WildcardOptions.IgnoreCase).IsMatch(commandName))
            {
                Results.DynamicObjectCreation.Add(commandAst);
            }
            else if (WildcardPattern.Get("Get-WmiObject", WildcardOptions.IgnoreCase).IsMatch(commandName))
            {
                Results.CmdletPipelineWrapping.Add(commandAst);
            }
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommandExpression(CommandExpressionAst commandExpressionAst)
    {
        if (commandExpressionAst.Expression is TypeExpressionAst typeAst &&
            typeAst.TypeName.Name.Equals("void", StringComparison.OrdinalIgnoreCase))
        {
            Results.OutputSuppression.Add(commandExpressionAst);
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitPipeline(PipelineAst pipelineAst)
    {
        if (pipelineAst.PipelineElements.Count > 0)
        {
            var lastElement = pipelineAst.PipelineElements[pipelineAst.PipelineElements.Count - 1] as CommandAst;
            if (lastElement != null && lastElement.CommandElements.Count > 0)
            {
                if (lastElement.CommandElements[lastElement.CommandElements.Count - 1] is StringConstantExpressionAst str &&
                    str.Value.Equals("Out-Null", StringComparison.OrdinalIgnoreCase))
                {
                    Results.OutputSuppression.Add(pipelineAst);
                }
            }
        }

        if (pipelineAst.PipelineElements.Count > 2)
        {
            Results.CmdletPipelineWrapping.Add(pipelineAst);
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitInvokeMemberExpression(InvokeMemberExpressionAst invokeMemberExpressionAst)
    {
        if (invokeMemberExpressionAst.Member != null)
        {
            var memberName = invokeMemberExpressionAst.Member.Value;
            if (memberName == "Add")
            {
                Results.ArrayAddition.Add(invokeMemberExpressionAst);
            }
            else if (memberName == "ReadLines" &&
                     invokeMemberExpressionAst.Expression is TypeExpressionAst typeAst &&
                     typeAst.TypeName.Name == "File")
            {
                Results.LargeFileProcessing.Add(invokeMemberExpressionAst);
            }
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitBinaryExpression(BinaryExpressionAst binaryExpressionAst)
    {
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
        if (expandableStringExpressionAst.NestedExpressions.Count > 0)
        {
            Results.StringAddition.Add(expandableStringExpressionAst);
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitTypeExpression(TypeExpressionAst typeExpressionAst)
    {
        if (typeExpressionAst.TypeName.Name == "StreamReader")
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
        if (Regex.IsMatch(functionDefinitionAst.Body.Extent.Text, "for\s*\(", RegexOptions.IgnoreCase))
        {
            Results.RepeatedFunctionCalls.Add(functionDefinitionAst);
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitConvertExpression(ConvertExpressionAst convertExpressionAst)
    {
        if (convertExpressionAst.Type.TypeName.Name.Equals("pscustomobject", StringComparison.OrdinalIgnoreCase))
        {
            Results.DynamicObjectCreation.Add(convertExpressionAst);
        }
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitMemberExpression(MemberExpressionAst memberExpressionAst)
    {
        if (memberExpressionAst.Member is StringConstantExpressionAst mem && mem.Value == "Properties" &&
            memberExpressionAst.Expression is TypeExpressionAst typeAst && typeAst.TypeName.Name == "PSObject")
        {
            Results.DynamicObjectCreation.Add(memberExpressionAst);
        }
        return AstVisitAction.Continue;
    }
}
