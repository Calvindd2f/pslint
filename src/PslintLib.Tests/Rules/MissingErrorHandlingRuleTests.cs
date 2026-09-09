using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class MissingErrorHandlingRuleTests
{
    private readonly MissingErrorHandlingRule _rule = new();

    [Fact]
    public void Analyze_RiskyCommandOutsideTry_Flags()
    {
        var ast = AstTestHelper.Parse("Invoke-RestMethod -Uri 'https://example.com'");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL013", finding.RuleId);
    }

    [Fact]
    public void Analyze_RiskyCommandInsideTry_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("try { Invoke-RestMethod -Uri 'https://example.com' } catch { throw }");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_SafeCommand_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("Get-Process");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
