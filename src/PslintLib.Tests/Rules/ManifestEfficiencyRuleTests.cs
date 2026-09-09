using System.Collections.Generic;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class ManifestEfficiencyRuleTests
{
    private readonly ManifestEfficiencyRule _rule = new();

    private const string ManifestWithWildcardExport = @"
@{
    ModuleVersion = '1.0.0'
    FunctionsToExport = '*'
    CmdletsToExport = @()
    AliasesToExport = @()
}";

    private const string ManifestWithExplicitExports = @"
@{
    ModuleVersion = '1.0.0'
    FunctionsToExport = @('Get-Thing')
    CmdletsToExport = @()
    AliasesToExport = @()
}";

    private const string ManifestMissingExportKeys = @"
@{
    ModuleVersion = '1.0.0'
}";

    [Fact]
    public void Analyze_WildcardExportAsManifest_Flags()
    {
        var ast = AstTestHelper.Parse(ManifestWithWildcardExport);
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: true, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL012", finding.RuleId);
    }

    [Fact]
    public void Analyze_WildcardExportWhenNotManifest_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(ManifestWithWildcardExport);
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: false, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_ExplicitExportArray_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(ManifestWithExplicitExports);
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: true, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_MissingExportKeys_FlagsOncePerMissingKey()
    {
        var ast = AstTestHelper.Parse(ManifestMissingExportKeys);
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: true, new RuleContext(findings));

        Assert.Equal(3, findings.Count);
    }
}
