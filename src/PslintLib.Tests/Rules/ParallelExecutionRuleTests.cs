using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class ParallelExecutionRuleTests
{
    private readonly ParallelExecutionRule _rule = new();

    [Fact]
    public void Analyze_StartJob_FlagsWithStartJobSuggestion()
    {
        var ast = AstTestHelper.Parse("Start-Job -ScriptBlock { 1 }");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL011", finding.RuleId);
        Assert.Contains("Start-ThreadJob", finding.Suggestion);
    }

    [Fact]
    public void Analyze_ForEachParallelWithoutThrottleLimit_FlagsWithThrottleSuggestion()
    {
        var ast = AstTestHelper.Parse("1..5 | ForEach-Object -Parallel { $_ }");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Contains("ThrottleLimit", finding.Suggestion);
    }

    [Fact]
    public void Analyze_ForEachParallelWithThrottleLimit_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("1..5 | ForEach-Object -Parallel { $_ } -ThrottleLimit 5");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_PlainForEachObject_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("1..5 | ForEach-Object { $_ }");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void TryFix_ForEachParallelWithoutThrottleLimit_AppendsDocumentedDefault()
    {
        var source = "1..5 | ForEach-Object -Parallel { $_ }";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<CommandAst>();

        var edit = _rule.TryFix(node, source);

        Assert.NotNull(edit);
        Assert.Equal(" -ThrottleLimit 5", edit!.Replacement);
        Assert.Equal(edit.StartOffset, edit.EndOffset); // pure insertion, nothing removed
    }

    [Fact]
    public void TryFix_ForEachParallelWithThrottleLimit_ReturnsNull()
    {
        var source = "1..5 | ForEach-Object -Parallel { $_ } -ThrottleLimit 5";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<CommandAst>();

        var edit = _rule.TryFix(node, source);

        Assert.Null(edit);
    }

    [Fact]
    public void TryFix_StartJob_ReturnsNull()
    {
        // Deliberately not auto-fixed: swapping to Start-ThreadJob pulls in a separate module and
        // changes variable-scoping/isolation semantics - not a mechanical, behavior-preserving edit.
        var source = "Start-Job -ScriptBlock { 1 }";
        var ast = AstTestHelper.Parse(source);
        var node = ast.FindFirstRequired<CommandAst>();

        var edit = _rule.TryFix(node, source);

        Assert.Null(edit);
    }
}
