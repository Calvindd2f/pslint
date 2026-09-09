using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL011: high-overhead parallelism (`Start-Job`) or `-Parallel` without an explicit `-ThrottleLimit`.</summary>
public sealed class ParallelExecutionRule : ICommandRule, IFixableRule
{
    private const string StartJobSuggestion =
        "Start-Job creates a new process for each job, which has high overhead. Consider Start-ThreadJob or ForEach-Object -Parallel instead.";

    private const string ThrottleLimitSuggestion =
        "When using ForEach-Object -Parallel, explicitly specify the -ThrottleLimit parameter. The default is 5, but you should balance overhead with the work being done.";

    public string Id => "PSL011";
    public string Name => "Parallel Execution Overhead";
    public string Category => "ParallelExecution";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion => ThrottleLimitSuggestion;

    public void Analyze(CommandAst ast, RuleContext context)
    {
        if (ast.CommandElements.Count == 0)
        {
            return;
        }

        var commandName = ast.CommandElements[0].ToString();

        if (string.Equals(commandName, "Start-Job", StringComparison.OrdinalIgnoreCase))
        {
            context.Report(this, ast, StartJobSuggestion);
            return;
        }

        if (IsForEachObjectMissingThrottleLimit(ast))
        {
            context.Report(this, ast, ThrottleLimitSuggestion);
        }
    }

    /// <summary>
    /// Only the missing-throttle-limit shape is fixed: appending the documented default
    /// (-ThrottleLimit 5) makes the implicit explicit without changing runtime behavior at all.
    /// Start-Job is deliberately NOT fixed - swapping it for Start-ThreadJob pulls in a separate
    /// module and changes variable-scoping/isolation semantics, which isn't a mechanical rewrite.
    /// </summary>
    public TextEdit? TryFix(Ast node, string sourceText)
    {
        if (node is not CommandAst ast || !IsForEachObjectMissingThrottleLimit(ast))
        {
            return null;
        }

        int end = ast.Extent.EndScriptPosition.Offset;
        return new TextEdit { StartOffset = end, EndOffset = end, Replacement = " -ThrottleLimit 5" };
    }

    private static bool IsForEachObjectMissingThrottleLimit(CommandAst ast)
    {
        if (ast.CommandElements.Count == 0)
        {
            return false;
        }

        var commandName = ast.CommandElements[0].ToString();
        bool isForEachObject =
            string.Equals(commandName, "ForEach-Object", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(commandName, "%", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(commandName, "foreach", StringComparison.OrdinalIgnoreCase);

        if (!isForEachObject)
        {
            return false;
        }

        bool hasParallel = false;
        bool hasThrottleLimit = false;
        foreach (var element in ast.CommandElements)
        {
            if (element is CommandParameterAst paramAst)
            {
                if (paramAst.ParameterName.StartsWith("Par", StringComparison.OrdinalIgnoreCase))
                    hasParallel = true;
                if (paramAst.ParameterName.StartsWith("Thr", StringComparison.OrdinalIgnoreCase))
                    hasThrottleLimit = true;
            }
        }

        return hasParallel && !hasThrottleLimit;
    }
}
