using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL007: a loop body long enough that its per-iteration cost is worth scrutinizing.</summary>
public sealed class LargeLoopsRule : ILoopBodyRule
{
    private const int MaxBodyLines = 15;

    public string Id => "PSL007";
    public string Name => "Large Loop Body";
    public string Category => "LargeLoops";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "Very large loops can be slow. Consider optimizing the logic inside the loop or exploring faster, array-based operations with .NET methods where possible.";

    public void Analyze(Ast loopAst, StatementBlockAst body, RuleContext context)
    {
        if (body.Extent.EndLineNumber - body.Extent.StartLineNumber > MaxBodyLines)
        {
            context.Report(this, loopAst);
        }
    }
}
