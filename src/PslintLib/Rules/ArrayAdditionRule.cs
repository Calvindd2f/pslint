using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL001: `+=` growing an array, or a plain `.Add(...)` call, each of which is worth a second look.</summary>
public sealed class ArrayAdditionRule : IAssignmentStatementRule, IInvokeMemberExpressionRule
{
    public string Id => "PSL001";
    public string Name => "Array Addition in Loop";
    public string Category => "ArrayAddition";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion =>
        "Using += on an array creates a new array and copies all elements on each call. For better performance, use [System.Collections.ArrayList] or [System.Collections.Generic.List[object]] and their .Add() method.";

    public void Analyze(AssignmentStatementAst ast, RuleContext context)
    {
        if (RuleHelpers.IsNonNumericPlusEquals(ast))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(InvokeMemberExpressionAst ast, RuleContext context)
    {
        if (ast.Member is StringConstantExpressionAst member && member.Value == "Add")
        {
            context.Report(this, ast);
        }
    }
}
