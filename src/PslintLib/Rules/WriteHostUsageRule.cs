using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL006: `Write-Host` writes directly to the console and can't be captured or redirected.</summary>
public sealed class WriteHostUsageRule : ICommandRule
{
    public string Id => "PSL006";
    public string Name => "Write-Host Usage";
    public string Category => "WriteHostUsage";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "Write-Host writes directly to the console, which can limit script portability and prevent capturing output. For general output, prefer Write-Output. For logging or debugging, consider Write-Verbose, Write-Debug, or a dedicated logging framework.";

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.CommandElements.Count > 0 &&
            string.Equals(ast.CommandElements[0].ToString(), "Write-Host", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast);
        }
    }
}
