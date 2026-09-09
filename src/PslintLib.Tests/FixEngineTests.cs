using System.Collections.Generic;
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
    public void ApplyFixes_SingleEdit_ReplacesExpectedRange()
    {
        var source = "Get-Process | Out-Null";
        var edit = new TextEdit { StartOffset = 0, EndOffset = source.Length, Replacement = "[void](Get-Process)" };

        var result = FixEngine.ApplyFixes(source, new List<TextEdit> { edit });

        Assert.Equal("[void](Get-Process)", result);
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

        Assert.Equal("YYYY ZZZZ", result);
    }

    [Fact]
    public void ApplyFixes_OverlappingEdits_KeepsLaterOneAndSkipsEarlier()
    {
        var source = "0123456789";
        var edits = new List<TextEdit>
        {
            new() { StartOffset = 0, EndOffset = 6, Replacement = "EARLY" },  // overlaps the next
            new() { StartOffset = 4, EndOffset = 10, Replacement = "LATER" }, // applied first (higher start)
        };

        var result = FixEngine.ApplyFixes(source, edits);

        // The [4,10) edit applies first (descending StartOffset), producing "0123LATER".
        // The [0,6) edit's EndOffset (6) exceeds the applied edit's start (4), so it's skipped.
        Assert.Equal("0123LATER", result);
    }

    [Fact]
    public void ApplyFixes_PureInsertion_DoesNotRemoveSurroundingText()
    {
        var source = "1..5 | ForEach-Object -Parallel { $_ }";
        var edit = new TextEdit { StartOffset = source.Length, EndOffset = source.Length, Replacement = " -ThrottleLimit 5" };

        var result = FixEngine.ApplyFixes(source, new List<TextEdit> { edit });

        Assert.Equal(source + " -ThrottleLimit 5", result);
    }
}
