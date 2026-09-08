using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL004: whole-file-into-memory patterns (`Get-Content`, `[File]::ReadLines`, `[StreamReader]`).</summary>
public sealed class LargeFileProcessingRule : ICommandRule, IInvokeMemberExpressionRule, ITypeExpressionRule
{
    public string Id => "PSL004";
    public string Name => "Large File Processing";
    public string Category => "LargeFileProcessing";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion =>
        "For large files, Get-Content can consume a lot of memory. Consider using System.IO.StreamReader for more efficient line-by-line processing.";

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.CommandElements.Count > 0 &&
            string.Equals(ast.CommandElements[0].ToString(), "Get-Content", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(InvokeMemberExpressionAst ast, RuleContext context)
    {
        if (ast.Member is StringConstantExpressionAst member &&
            member.Value == "ReadLines" &&
            ast.Expression is TypeExpressionAst typeExpr &&
            typeExpr.TypeName.Name == "File")
        {
            context.Report(this, ast);
        }
    }

    public void Analyze(TypeExpressionAst ast, RuleContext context)
    {
        if (string.Equals(ast.TypeName.Name, "StreamReader", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }
}
