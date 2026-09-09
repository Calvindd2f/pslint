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
/// Outcome of applying a batch of edits. Applied/Skipped partition the input exactly - every edit
/// passed to ApplyFixes ends up in exactly one of the two lists, by reference - so a caller can
/// tell a candidate that landed in Text from one the overlap guard dropped, rather than assuming
/// "I asked for N fixes" means "N fixes happened".
/// </summary>
public class FixApplicationResult
{
    public string Text { get; set; } = string.Empty;
    public List<TextEdit> Applied { get; set; } = new();
    public List<TextEdit> Skipped { get; set; } = new();
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
    /// applied. If two edits do overlap (which would mean two rules tried to rewrite overlapping
    /// spans - e.g. a fix on a ForEach-Object command nested inside a pipeline another rule is
    /// rewriting whole), the one starting later in the source is kept and the other is reported
    /// back in Skipped rather than silently dropped or risking corrupted output. A second -Fix
    /// pass after the first is applied will typically pick up whatever was skipped, since the
    /// overlap that caused the skip is usually resolved once the winning edit has landed.
    /// </summary>
    public static FixApplicationResult ApplyFixes(string sourceText, IEnumerable<TextEdit> edits)
    {
        var ordered = edits.OrderByDescending(e => e.StartOffset).ToList();
        var result = new StringBuilder(sourceText);
        var applied = new List<TextEdit>();
        var skipped = new List<TextEdit>();
        var earliestAppliedStart = sourceText.Length + 1;

        foreach (var edit in ordered)
        {
            if (edit.EndOffset > earliestAppliedStart)
            {
                skipped.Add(edit);
                continue;
            }

            result.Remove(edit.StartOffset, edit.EndOffset - edit.StartOffset);
            result.Insert(edit.StartOffset, edit.Replacement);
            earliestAppliedStart = edit.StartOffset;
            applied.Add(edit);
        }

        return new FixApplicationResult { Text = result.ToString(), Applied = applied, Skipped = skipped };
    }
}
