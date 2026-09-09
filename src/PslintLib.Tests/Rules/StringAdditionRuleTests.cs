using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class StringAdditionRuleTests
{
    private readonly StringAdditionRule _rule = new();

    [Fact]
    public void Analyze_NonNumericPlusEquals_Flags()
    {
        var ast = AstTestHelper.Parse("$s += \"text\"");
        var node = ast.FindFirstRequired<AssignmentStatementAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL002", finding.RuleId);
        Assert.Equal("StringAddition", finding.Category);
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
    public void Analyze_PlusWithStringOperand_Flags()
    {
        var ast = AstTestHelper.Parse("\"a\" + $b");
        var node = ast.FindFirstRequired<BinaryExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_PlusWithTwoNumbers_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("1 + 2");
        var node = ast.FindFirstRequired<BinaryExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_FormatOperator_Flags()
    {
        var ast = AstTestHelper.Parse("\"{0}\" -f $x");
        var node = ast.FindFirstRequired<BinaryExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_InterpolatedString_Flags()
    {
        var ast = AstTestHelper.Parse("\"value: $($x)\"");
        var node = ast.FindFirstRequired<ExpandableStringExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }
}
