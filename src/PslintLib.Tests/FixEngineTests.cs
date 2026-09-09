using System.Collections.Generic;
using System.Linq;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests;

public class FixEngineTests
{
    private static CodeAnalysisResults AnalyzeSnippet(string script)
    {
        var ast = AstTestHelper.Parse(script);
        return RuleEngine.Analyze(ast, isManifest: false);
    }

    [Fact]
    public void CollectFixes_OnlyIncludesFixableRuleFindings()
    {
        // Get-Process (PSL013 MissingErrorHandling would not fire here, but WriteHostUsage/PSL006
        // is NOT fixable) sits alongside a genuinely fixable Out-Null suppression.
        var source = "Write-Host 'hi'\nGet-Process | Out-Null";
        var results = AnalyzeSnippet(source);

        var fixes = FixEngine.CollectFixes(results, source);

        var fix = Assert.Single(fixes);
        Assert.Equal("PSL003", fix.Finding.RuleId);
    }

    [Fact]
    public void CollectFixes_NoFixableFindings_ReturnsEmpty()
    {
        var source = "Write-Host 'hi'";
        var results = AnalyzeSnippet(source);

        var fixes = FixEngine.CollectFixes(results, source);

        Assert.Empty(fixes);
    }

    [Fact]
    public void ApplyFixes_SingleEdit_ReplacesExpectedRangeAndReportsApplied()
    {
        var source = "Get-Process | Out-Null";
        var edit = new TextEdit { StartOffset = 0, EndOffset = source.Length, Replacement = "[void](Get-Process)" };

        var result = FixEngine.ApplyFixes(source, new List<TextEdit> { edit });

        Assert.Equal("[void](Get-Process)", result.Text);
        Assert.Same(edit, Assert.Single(result.Applied));
        Assert.Empty(result.Skipped);
    }

    [Fact]
    public void ApplyFixes_MultipleNonOverlappingEdits_AppliesAllRegardlessOfInputOrder()
    {
        var source = "AAAA BBBB";
        var edits = new List<TextEdit>
        {
            new() { StartOffset = 5, EndOffset = 9, Replacement = "ZZZZ" }, // "BBBB" -> "ZZZZ"
            new() { StartOffset = 0, EndOffset = 4, Replacement = "YYYY" }, // "AAAA" -> "YYYY"
        };

        var result = FixEngine.ApplyFixes(source, edits);

        Assert.Equal("YYYY ZZZZ", result.Text);
        Assert.Equal(2, result.Applied.Count);
        Assert.Empty(result.Skipped);
    }

    [Fact]
    public void ApplyFixes_OverlappingEdits_KeepsLaterOneAndReportsEarlierAsSkipped()
    {
        var source = "0123456789";
        var early = new TextEdit { StartOffset = 0, EndOffset = 6, Replacement = "EARLY" };  // overlaps the next
        var later = new TextEdit { StartOffset = 4, EndOffset = 10, Replacement = "LATER" }; // applied first (higher start)

        var result = FixEngine.ApplyFixes(source, new List<TextEdit> { early, later });

        // The [4,10) edit applies first (descending StartOffset), producing "0123LATER".
        // The [0,6) edit's EndOffset (6) exceeds the applied edit's start (4), so it's skipped -
        // and, critically, reported as skipped rather than silently counted as applied.
        Assert.Equal("0123LATER", result.Text);
        Assert.Same(later, Assert.Single(result.Applied));
        Assert.Same(early, Assert.Single(result.Skipped));
    }

    [Fact]
    public void ApplyFixes_PureInsertion_DoesNotRemoveSurroundingText()
    {
        var source = "1..5 | ForEach-Object -Parallel { $_ }";
        var edit = new TextEdit { StartOffset = source.Length, EndOffset = source.Length, Replacement = " -ThrottleLimit 5" };

        var result = FixEngine.ApplyFixes(source, new List<TextEdit> { edit });

        Assert.Equal(source + " -ThrottleLimit 5", result.Text);
    }

    [Fact]
    public void EndToEnd_ThrottleLimitInsertionNestedInsideOutNullPipeline_ThrottleFixWinsAndSuppressionFixIsSkipped()
    {
        // Regression test for a real bug found via manual testing: ForEach-Object -Parallel piped
        // to Out-Null produces two overlapping edits - PSL011's insertion sits strictly inside the
        // span PSL003's pipeline rewrite would replace. Both used to get counted as "applied" by
        // the caller even though only one edit could land without corrupting the file.
        var source = "1..5 | ForEach-Object -Parallel { $_ * 2 } | Out-Null";
        var results = AnalyzeSnippet(source);

        var fixes = FixEngine.CollectFixes(results, source);
        Assert.Equal(2, fixes.Count); // both PSL003 and PSL011 produce a candidate edit here

        var result = FixEngine.ApplyFixes(source, fixes.Select(f => f.Edit));

        Assert.Single(result.Applied);
        Assert.Single(result.Skipped);
        // The throttle-limit insertion (nested, higher StartOffset) wins; the suppression rewrite
        // (wraps the whole pipeline, lower StartOffset) is the one skipped.
        Assert.Equal(" -ThrottleLimit 5", result.Applied.Single().Replacement);
        Assert.StartsWith("[void](", result.Skipped.Single().Replacement);
        Assert.Equal("1..5 | ForEach-Object -Parallel { $_ * 2 } -ThrottleLimit 5 | Out-Null", result.Text);

        // A second pass, re-analyzing the now-fixed text, should pick up what the first pass
        // skipped - the overlap that caused the skip no longer exists once ThrottleLimit landed.
        var secondPassResults = AnalyzeSnippet(result.Text);
        var secondPassFixes = FixEngine.CollectFixes(secondPassResults, result.Text);
        var secondPassApply = FixEngine.ApplyFixes(result.Text, secondPassFixes.Select(f => f.Edit));

        Assert.Empty(secondPassApply.Skipped);
        Assert.Equal("[void](1..5 | ForEach-Object -Parallel { $_ * 2 } -ThrottleLimit 5)", secondPassApply.Text);
    }
}
