using System;
using System.Linq;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests;

public class AnalyzerTests
{
    [Fact]
    public void AnalyzeText_ValidScript_ReturnsFindings()
    {
        var results = Analyzer.AnalyzeText("Write-Host 'hi'");

        var finding = Assert.Single(results.Findings);
        Assert.Equal("PSL006", finding.RuleId);
    }

    [Fact]
    public void AnalyzeText_FindingNodeExtentOffsets_AreRelativeToTheGivenText()
    {
        // The whole point of AnalyzeText over reusing an existing Ast: offsets must be trustworthy
        // for slicing the exact string that was passed in.
        var source = "Get-Process | Out-Null";
        var results = Analyzer.AnalyzeText(source);

        var finding = results.Findings.Single(f => f.RuleId == "PSL003");
        var extent = finding.Node!.Extent;
        var sliced = source.Substring(extent.StartScriptPosition.Offset,
            extent.EndScriptPosition.Offset - extent.StartScriptPosition.Offset);

        Assert.Equal(source, sliced);
    }

    [Fact]
    public void AnalyzeText_InvalidScript_ThrowsWithParseErrorDetails()
    {
        var ex = Assert.Throws<InvalidOperationException>(() => Analyzer.AnalyzeText("function {"));
        Assert.Contains("Parse errors", ex.Message);
    }

    [Fact]
    public void AnalyzeText_ManifestContent_RunsManifestRulesWhenFlagged()
    {
        var results = Analyzer.AnalyzeText("@{ FunctionsToExport = '*' }", isManifest: true);

        Assert.Contains(results.Findings, f => f.RuleId == "PSL012");
    }
}
