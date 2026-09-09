using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL015: the same statement repeated three or more times, a candidate for extracting a function or loop.</summary>
public sealed class DuplicatedCodeBlocksRule : IWholeAstRule
{
    private const int MinimumOccurrences = 3;

    public string Id => "PSL015";
    public string Name => "Duplicated Code Block";
    public string Category => "DuplicatedCodeBlocks";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "This statement is repeated three or more times in the script. Consider extracting it into a function or loop to reduce duplication and centralize future changes.";

    public void Analyze(Ast root, bool isManifest, RuleContext context)
    {
        var candidates = root.FindAll(IsDuplicateCandidate, true);

        var groups = candidates
            .Cast<Ast>()
            .GroupBy(a => NormalizeText(a.Extent.Text));

        foreach (var group in groups)
        {
            var occurrences = group.ToList();
            if (occurrences.Count >= MinimumOccurrences)
            {
                foreach (var occurrence in occurrences)
                {
                    context.Report(this, occurrence);
                }
            }
        }
    }

    private static bool IsDuplicateCandidate(Ast ast)
    {
        return (ast is PipelineAst || ast is AssignmentStatementAst) &&
               ast.Parent is StatementBlockAst or NamedBlockAst;
    }

    private static string NormalizeText(string text)
    {
        return string.Join(" ", text.Split(
            new[] { ' ', '\t', '\r', '\n' },
            System.StringSplitOptions.RemoveEmptyEntries));
    }
}
