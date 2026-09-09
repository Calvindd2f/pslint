using System.Collections.Generic;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class DuplicatedCodeBlocksRuleTests
{
    private readonly DuplicatedCodeBlocksRule _rule = new();

    [Fact]
    public void Analyze_StatementRepeatedThreeTimes_FlagsEachOccurrence()
    {
        var ast = AstTestHelper.Parse(@"
Write-Output 'the same statement'
Write-Output 'the same statement'
Write-Output 'the same statement'");
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: false, new RuleContext(findings));

        Assert.Equal(3, findings.Count);
        Assert.All(findings, f => Assert.Equal("PSL015", f.RuleId));
    }

    [Fact]
    public void Analyze_StatementRepeatedTwice_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(@"
Write-Output 'the same statement'
Write-Output 'the same statement'");
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: false, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_DistinctStatements_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(@"
Write-Output 'first statement'
Write-Output 'second statement'
Write-Output 'third statement'");
        var findings = new List<Finding>();

        _rule.Analyze(ast, isManifest: false, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
