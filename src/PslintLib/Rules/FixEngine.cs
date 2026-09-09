using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PslintLib.Analysis;

/// <summary>A fix collected for one finding, ready to apply.</summary>
public class FixCandidate
{
    public Finding Finding { get; set; } = new();
    public TextEdit Edit { get; set; } = new();
}

/// <summary>
/// Collects and applies the safe, mechanical fixes available for a set of findings. Only findings
/// whose originating rule implements IFixableRule - and whose specific node shape that rule
/// chooses to fix - produce an edit; everything else is left for the human to judge.
/// </summary>
public static class FixEngine
{
    public static List<FixCandidate> CollectFixes(CodeAnalysisResults results, string sourceText)
    {
        var rulesById = RuleRegistry.AllRules.ToDictionary(r => r.Id);
        var candidates = new List<FixCandidate>();

        foreach (var finding in results.Findings)
        {
            if (finding.Node is null)
            {
                continue;
            }

            if (!rulesById.TryGetValue(finding.RuleId, out var rule) || rule is not IFixableRule fixable)
            {
                continue;
            }

            var edit = fixable.TryFix(finding.Node, sourceText);
            if (edit != null)
            {
                candidates.Add(new FixCandidate { Finding = finding, Edit = edit });
            }
        }

        return candidates;
    }

    /// <summary>
    /// Applies non-overlapping edits back-to-front so earlier offsets stay valid as later ones are
    /// applied. If two edits do overlap (which would mean two rules tried to rewrite the same
    /// span), the later one in source order is kept and the earlier one is skipped rather than
    /// risking corrupted output.
    /// </summary>
    public static string ApplyFixes(string sourceText, IEnumerable<TextEdit> edits)
    {
        var ordered = edits.OrderByDescending(e => e.StartOffset).ToList();
        var result = new StringBuilder(sourceText);
        var earliestAppliedStart = sourceText.Length + 1;

        foreach (var edit in ordered)
        {
            if (edit.EndOffset > earliestAppliedStart)
            {
                continue;
            }

            result.Remove(edit.StartOffset, edit.EndOffset - edit.StartOffset);
            result.Insert(edit.StartOffset, edit.Replacement);
            earliestAppliedStart = edit.StartOffset;
        }

        return result.ToString();
    }
}
