using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL010: ad hoc object shaping via `Add-Member`, `[pscustomobject]`, or `[PSObject]::Properties`.</summary>
public sealed class DynamicObjectCreationRule : ICommandRule, IConvertExpressionRule, IMemberExpressionRule
{
    public string Id => "PSL010";
    public string Name => "Dynamic Object Creation";
    public string Category => "DynamicObjectCreation";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "Creating custom objects with `[PSCustomObject]` or `Add-Member` inside loops can be slow. For performance-critical scenarios, consider defining a class.";

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.CommandElements.Count > 0 &&
            string.Equals(ast.CommandElements[0].ToString(), "Add-Member", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(ConvertExpressionAst ast, RuleContext context)
    {
        if (string.Equals(ast.Type.TypeName.Name, "pscustomobject", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(MemberExpressionAst ast, RuleContext context)
    {
        if (ast.Member is StringConstantExpressionAst member &&
            member.Value == "Properties" &&
            ast.Expression is TypeExpressionAst typeExpr &&
            typeExpr.TypeName.Name == "PSObject")
        {
            context.Report(this, ast);
        }
    }
}
