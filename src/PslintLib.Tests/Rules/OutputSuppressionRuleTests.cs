using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class OutputSuppressionRuleTests
{
    private readonly OutputSuppressionRule _rule = new();

    [Fact]
    public void Analyze_AssignmentToNull_Flags()
    {
        var ast = AstTestHelper.Parse("$result = $null");
        var node = ast.FindFirstRequired<AssignmentStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL003", finding.RuleId);
    }

    [Fact]
    public void Analyze_AssignmentToNonNullValue_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("$result = 5");
        var node = ast.FindFirstRequired<AssignmentStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_RedirectToNull_Flags()
    {
        var ast = AstTestHelper.Parse("Get-Process >$null");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_PlainCommand_DoesNotFlagViaRedirection()
    {
        var ast = AstTestHelper.Parse("Get-Process");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_BareVoidTypeLiteral_Flags()
    {
        // NOTE: only a bare `[void]` expression statement hits this branch. The common
        // real-world idiom `[void](Get-Process)` parses as a ConvertExpressionAst, not a
        // CommandExpressionAst wrapping a TypeExpressionAst, so this detection path does not
        // fire for it. Pre-existing behavior, preserved as-is by the rule-plugin refactor.
        var ast = AstTestHelper.Parse("[void]");
        var node = ast.FindFirstRequired<CommandExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_PipedToOutNull_Flags()
    {
        var ast = AstTestHelper.Parse("Get-Process | Out-Null");
        var node = ast.FindFirstRequired<PipelineAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_PipedToOutHost_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("Get-Process | Out-Host");
        var node = ast.FindFirstRequired<PipelineAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
