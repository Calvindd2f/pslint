using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL013: a call that can plausibly throw (network, module, or connection failures) outside any try block.</summary>
public sealed class MissingErrorHandlingRule : ICommandRule
{
    private static readonly string[] RiskyCommands =
    {
        "Invoke-RestMethod",
        "Invoke-WebRequest",
        "Import-Module",
        "New-Object",
        "Invoke-Command"
    };

    public string Id => "PSL013";
    public string Name => "Missing Error Handling";
    public string Category => "MissingErrorHandling";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion =>
        "This call can throw (network, module, or connection failures). Wrap it in a try/catch block so failures are handled predictably instead of terminating the script or being silently swallowed by calling code.";

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.CommandElements.Count == 0)
        {
            return;
        }

        var commandName = ast.CommandElements[0].ToString();

        foreach (var riskyCommand in RiskyCommands)
        {
            if (string.Equals(commandName, riskyCommand, StringComparison.OrdinalIgnoreCase) &&
                !RuleHelpers.IsInsideTryStatement(ast))
            {
                context.Report(this, ast);
                break;
            }
        }
    }
}
