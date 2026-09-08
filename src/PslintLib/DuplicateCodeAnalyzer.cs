using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public static class DuplicateCodeAnalyzer
{
    private const int MinimumOccurrences = 3;

    public static void Analyze(Ast ast, CodeAnalysisResults results)
    {
        var candidates = ast.FindAll(a => IsDuplicateCandidate(a), true);

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
                    results.DuplicatedCodeBlocks.Add(occurrence);
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
