using System.Collections.Generic;
using System.Linq;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests;

public class SarifGeneratorTests
{
    private static CodeAnalysisResults AnalyzeSnippet(string script)
    {
        var ast = AstTestHelper.Parse(script);
        return RuleEngine.Analyze(ast, isManifest: false);
    }

    [Fact]
    public void Generate_DriverRules_CoversFullCatalogInOrder()
    {
        var results = AnalyzeSnippet("Write-Host 'hi'");

        var log = SarifGenerator.Generate(results, "script.ps1");

        var driverRules = log.Runs.Single().Tool.Driver.Rules;
        Assert.Equal(RuleRegistry.AllRules.Select(r => r.Id), driverRules.Select(r => r.Id));
    }

    [Fact]
    public void Generate_Finding_MapsRuleIdSeverityAndLocation()
    {
        var results = AnalyzeSnippet("Write-Host 'hi'");

        var log = SarifGenerator.Generate(results, "script.ps1");

        var result = Assert.Single(log.Runs.Single().Results);
        Assert.Equal("PSL006", result.RuleId);
        Assert.Equal("note", result.Level); // WriteHostUsageRule is Severity.Info
        Assert.True(result.RuleIndex >= 0);

        var location = Assert.Single(result.Locations);
        Assert.Equal("script.ps1", location.PhysicalLocation.ArtifactLocation.Uri);
        Assert.NotNull(location.PhysicalLocation.Region);
        Assert.Equal(1, location.PhysicalLocation.Region!.StartLine);
    }

    [Theory]
    [InlineData(Severity.Error, "error")]
    [InlineData(Severity.Warning, "warning")]
    [InlineData(Severity.Info, "note")]
    public void Generate_SeverityLevels_MapToSarifLevels(Severity severity, string expectedLevel)
    {
        var findings = new List<Finding>
        {
            new()
            {
                RuleId = "PSL999",
                Category = "Test",
                Severity = severity,
                Suggestion = "test"
            }
        };
        var results = new CodeAnalysisResults(findings);

        var log = SarifGenerator.Generate(results, "script.ps1");

        Assert.Equal(expectedLevel, log.Runs.Single().Results.Single().Level);
    }

    [Fact]
    public void Generate_NullScriptPath_UsesScriptBlockArtifactUri()
    {
        var results = AnalyzeSnippet("Write-Host 'hi'");

        var log = SarifGenerator.Generate(results, null);

        var uri = log.Runs.Single().Results.Single().Locations.Single().PhysicalLocation.ArtifactLocation.Uri;
        Assert.Equal("ScriptBlock", uri);
    }

    [Fact]
    public void Generate_WindowsPath_NormalizesToForwardSlashes()
    {
        var results = AnalyzeSnippet("Write-Host 'hi'");

        var log = SarifGenerator.Generate(results, @"C:\scripts\script.ps1");

        var uri = log.Runs.Single().Results.Single().Locations.Single().PhysicalLocation.ArtifactLocation.Uri;
        Assert.Equal("C:/scripts/script.ps1", uri);
    }
}
