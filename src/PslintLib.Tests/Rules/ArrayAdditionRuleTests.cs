using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class ArrayAdditionRuleTests
{
    private readonly ArrayAdditionRule _rule = new();

    [Fact]
    public void Analyze_NonNumericPlusEquals_Flags()
    {
        var ast = AstTestHelper.Parse("$items += $item");
        var node = ast.FindFirstRequired<AssignmentStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL001", finding.RuleId);
        Assert.Equal("ArrayAddition", finding.Category);
    }

    [Fact]
    public void Analyze_NumericConstantPlusEquals_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("$count += 1");
        var node = ast.FindFirstRequired<AssignmentStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_AddMethodCall_Flags()
    {
        var ast = AstTestHelper.Parse("$list.Add($item)");
        var node = ast.FindFirstRequired<InvokeMemberExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL001", finding.RuleId);
    }

    [Fact]
    public void Analyze_UnrelatedMethodCall_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("$list.Contains($item)");
        var node = ast.FindFirstRequired<InvokeMemberExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
