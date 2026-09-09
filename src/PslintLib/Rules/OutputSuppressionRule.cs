using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL003: output suppressed via `$null =`, `&gt;$null`, `[void]`, or `Out-Null`.</summary>
public sealed class OutputSuppressionRule :
    IAssignmentStatementRule, ICommandRule, ICommandExpressionRule, IPipelineRule, IFixableRule
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

    /// <summary>
    /// Only the Out-Null-pipeline and &gt;$null-redirection shapes are fixed, both by rewriting to
    /// [void](...) - the tool's own recommended style, and behaviorally equivalent to what they
    /// replace. The `$x = $null` assignment shape is deliberately NOT fixed here: despite sharing
    /// this rule's category, it isn't actually output suppression - it assigns $null to a variable,
    /// and rewriting it to a void cast would silently stop that assignment from happening. The bare
    /// `[void]` type-literal shape needs no fix (it's already the target form).
    /// </summary>
    public TextEdit? TryFix(Ast node, string sourceText)
    {
        return node switch
        {
            PipelineAst pipeline => TryFixOutNullPipeline(pipeline, sourceText),
            CommandAst command => TryFixNullRedirection(command, sourceText),
            _ => null
        };
    }

    private static TextEdit? TryFixOutNullPipeline(PipelineAst ast, string sourceText)
    {
        // Need at least one element besides the trailing "Out-Null" to wrap in [void](...).
        if (ast.PipelineElements.Count < 2)
        {
            return null;
        }

        var lastKept = ast.PipelineElements[ast.PipelineElements.Count - 2];
        int start = ast.Extent.StartScriptPosition.Offset;
        int keptEnd = lastKept.Extent.EndScriptPosition.Offset;
        int end = ast.Extent.EndScriptPosition.Offset;

        var keptText = sourceText.Substring(start, keptEnd - start);
        return new TextEdit { StartOffset = start, EndOffset = end, Replacement = $"[void]({keptText})" };
    }

    private static TextEdit? TryFixNullRedirection(CommandAst ast, string sourceText)
    {
        // Only rewrite the single, unambiguous ">$null" redirection this rule detects. A command
        // with additional redirections (e.g. a separate 2>$null for errors) is left alone, since
        // wrapping the bare command text in [void](...) would silently drop those too.
        if (ast.Redirections.Count != 1 || ast.CommandElements.Count == 0)
        {
            return null;
        }

        if (ast.Redirections[0]?.ToString() != ">$null")
        {
            return null;
        }

        int start = ast.Extent.StartScriptPosition.Offset;
        int cmdEnd = ast.CommandElements[ast.CommandElements.Count - 1].Extent.EndScriptPosition.Offset;
        int end = ast.Extent.EndScriptPosition.Offset;

        var cmdText = sourceText.Substring(start, cmdEnd - start);
        return new TextEdit { StartOffset = start, EndOffset = end, Replacement = $"[void]({cmdText})" };
    }
}
