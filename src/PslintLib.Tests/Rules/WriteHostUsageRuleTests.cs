using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class WriteHostUsageRuleTests
{
    private readonly WriteHostUsageRule _rule = new();

    [Fact]
    public void Analyze_WriteHost_Flags()
    {
        var ast = AstTestHelper.Parse("Write-Host 'hi'");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL006", finding.RuleId);
    }

    [Fact]
    public void Analyze_WriteOutput_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("Write-Output 'hi'");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
