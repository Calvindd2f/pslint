using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL009: obsolete/wrapping cmdlets (`Get-WmiObject`) or long pipelines that could filter at the source.</summary>
public sealed class CmdletPipelineWrappingRule : ICommandRule, IPipelineRule
{
    private const string WmiSuggestion =
        "`Get-WmiObject` is obsolete. Use `Get-CimInstance` instead. Also, try to use a `-Filter` parameter instead of piping to `Where-Object` to improve performance by filtering at the source.";

    private const string PipelineSuggestion =
        "Piping to `Where-Object` can be inefficient for large datasets. Where possible, use a cmdlet-specific `-Filter` parameter to filter results at the source. Long pipelines can also be harder to read and debug.";

    public string Id => "PSL009";
    public string Name => "Cmdlet Pipeline Wrapping";
    public string Category => "CmdletPipelineWrapping";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion => PipelineSuggestion;

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.CommandElements.Count > 0 &&
            string.Equals(ast.CommandElements[0].ToString(), "Get-WmiObject", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast, WmiSuggestion);
        }
    }

    public void Analyze(PipelineAst ast, RuleContext context)
    {
        if (ast.PipelineElements.Count > 2)
        {
            var suggestion = ast.Extent.Text.IndexOf("Get-WmiObject", StringComparison.OrdinalIgnoreCase) >= 0
                ? WmiSuggestion
                : PipelineSuggestion;
            context.Report(this, ast, suggestion);
        }
    }
}
