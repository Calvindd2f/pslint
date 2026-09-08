using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL002: repeated string concatenation via `+=`, `+`/`-f`, or nested-expression string interpolation.</summary>
public sealed class StringAdditionRule : IAssignmentStatementRule, IBinaryExpressionRule, IExpandableStringExpressionRule
{
    public string Id => "PSL002";
    public string Name => "String Concatenation";
    public string Category => "StringAddition";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "Repeated string concatenation can be inefficient. For complex strings, consider using the -f format operator, -join, or System.Text.StringBuilder.";

    public void Analyze(AssignmentStatementAst ast, RuleContext context)
    {
        if (RuleHelpers.IsNonNumericPlusEquals(ast))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(BinaryExpressionAst ast, RuleContext context)
    {
        if (ast.Operator == TokenKind.Format ||
            (ast.Operator == TokenKind.Plus &&
             (ast.Left is StringConstantExpressionAst || ast.Right is StringConstantExpressionAst)))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(ExpandableStringExpressionAst ast, RuleContext context)
    {
        if (ast.NestedExpressions.Count > 0)
        {
            context.Report(this, ast);
        }
    }
}
