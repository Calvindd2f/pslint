using System.Management.Automation.Language;
using System.Text.RegularExpressions;

namespace PslintLib.Analysis;

/// <summary>PSL008: a function whose body contains a C-style `for (...)` loop, a common spot for redundant repeated calls.</summary>
public sealed class RepeatedFunctionCallsRule : IFunctionDefinitionRule
{
    public string Id => "PSL008";
    public string Name => "Repeated Function Calls";
    public string Category => "RepeatedFunctionCalls";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "Calling the same function repeatedly with the same parameters can be inefficient. Consider caching the results in a variable.";

    public void Analyze(FunctionDefinitionAst ast, RuleContext context)
    {
        if (Regex.IsMatch(ast.Body.Extent.Text, @"for\s*\(", RegexOptions.IgnoreCase))
        {
            context.Report(this, ast);
        }
    }
}
