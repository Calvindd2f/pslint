using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL003: output suppressed via `$null =`, `&gt;$null`, `[void]`, or `Out-Null`.</summary>
public sealed class OutputSuppressionRule :
    IAssignmentStatementRule, ICommandRule, ICommandExpressionRule, IPipelineRule
{
    public string Id => "PSL003";
    public string Name => "Output Suppression";
    public string Category => "OutputSuppression";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "Consider using [void] for performance and clarity instead of piping to Out-Null or assigning to $null.";

    public void Analyze(AssignmentStatementAst ast, RuleContext context)
    {
        if (ast.Right is CommandExpressionAst cmdExpr &&
            cmdExpr.Expression is VariableExpressionAst rightVar &&
            rightVar.VariablePath.UserPath == "null")
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.Redirections.Count > 0 &&
            ast.Redirections[0] != null &&
            ast.Redirections[0].ToString() == ">$null")
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(CommandExpressionAst ast, RuleContext context)
    {
        if (ast.Expression is TypeExpressionAst typeExpr &&
            string.Equals(typeExpr.TypeName.Name, "void", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(PipelineAst ast, RuleContext context)
    {
        if (ast.PipelineElements.Count > 0 &&
            ast.PipelineElements[ast.PipelineElements.Count - 1] is CommandAst lastElement &&
            lastElement.CommandElements.Count > 0 &&
            lastElement.CommandElements[lastElement.CommandElements.Count - 1] is StringConstantExpressionAst str &&
            str.Value.Equals("Out-Null", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }
}
