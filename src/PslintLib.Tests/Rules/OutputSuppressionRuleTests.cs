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

    [Fact]
    public void TryFix_SingleElementOutNullPipeline_RewritesToVoidCast()
    {
        var source = "Get-Process | Out-Null";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<PipelineAst>();

        var edit = _rule.TryFix(node, source);

        Assert.NotNull(edit);
        Assert.Equal("[void](Get-Process)", edit!.Replacement);
    }

    [Fact]
    public void TryFix_MultiElementOutNullPipeline_KeepsUpstreamPipeline()
    {
        var source = "Get-Process | Where-Object { $_.CPU -gt 10 } | Out-Null";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<PipelineAst>();

        var edit = _rule.TryFix(node, source);

        Assert.NotNull(edit);
        Assert.Equal("[void](Get-Process | Where-Object { $_.CPU -gt 10 })", edit!.Replacement);
    }

    [Fact]
    public void TryFix_BareOutNullWithNoUpstream_ReturnsNull()
    {
        var source = "Out-Null";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<PipelineAst>();

        var edit = _rule.TryFix(node, source);

        Assert.Null(edit);
    }

    [Fact]
    public void TryFix_NullRedirection_RewritesToVoidCast()
    {
        var source = "Get-Process >$null";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<CommandAst>();

        var edit = _rule.TryFix(node, source);

        Assert.NotNull(edit);
        Assert.Equal("[void](Get-Process)", edit!.Replacement);
    }

    [Fact]
    public void TryFix_RedirectionWithAdditionalStreamRedirect_ReturnsNull()
    {
        // Only the single ">$null" shape this rule detects is fixable - a second redirection
        // (e.g. 2>$null for errors) would be silently dropped by a naive [void](...) rewrite,
        // so TryFix must decline rather than risk suppressing a stream nobody asked to suppress.
        var source = "Get-Process >$null 2>$null";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<CommandAst>();

        var edit = _rule.TryFix(node, source);

        Assert.Null(edit);
    }

    [Fact]
    public void TryFix_AssignmentToNull_ReturnsNull()
    {
        // This shape is deliberately never fixed: it isn't output suppression, it's a variable
        // assignment. Rewriting `$result = $null` to a void cast would silently stop $result from
        // being set, changing the script's behavior.
        var source = "$result = $null";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<AssignmentStatementAst>();

        var edit = _rule.TryFix(node, source);

        Assert.Null(edit);
    }
}
