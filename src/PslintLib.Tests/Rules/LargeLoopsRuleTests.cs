using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class LargeLoopsRuleTests
{
    private readonly LargeLoopsRule _rule = new();

    private static string Lines(int count) =>
        string.Join("\n", Enumerable.Range(1, count).Select(i => $"    Write-Output {i}"));

    [Fact]
    public void Analyze_ForEachWithLongBody_Flags()
    {
        var ast = AstTestHelper.Parse($"foreach ($i in 1..10) {{\n{Lines(20)}\n}}");
        var loop = ast.FindFirstRequired<ForEachStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(loop, loop.Body, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL007", finding.RuleId);
    }

    [Fact]
    public void Analyze_ForEachWithShortBody_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse($"foreach ($i in 1..10) {{\n{Lines(3)}\n}}");
        var loop = ast.FindFirstRequired<ForEachStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(loop, loop.Body, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_WhileWithLongBody_Flags()
    {
        var ast = AstTestHelper.Parse($"while ($true) {{\n{Lines(20)}\n}}");
        var loop = ast.FindFirstRequired<WhileStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(loop, loop.Body, new RuleContext(findings));

        Assert.Single(findings);
    }
}
