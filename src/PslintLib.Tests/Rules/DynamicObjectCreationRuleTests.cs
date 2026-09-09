using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class DynamicObjectCreationRuleTests
{
    private readonly DynamicObjectCreationRule _rule = new();

    [Fact]
    public void Analyze_AddMemberCommand_Flags()
    {
        var ast = AstTestHelper.Parse("Add-Member -InputObject $obj -Name Foo -Value 1");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL010", finding.RuleId);
    }

    [Fact]
    public void Analyze_UnrelatedCommand_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("Get-Process");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_PsCustomObjectConversion_Flags()
    {
        var ast = AstTestHelper.Parse("[pscustomobject]@{Name='x'}");
        var node = ast.FindFirstRequired<ConvertExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_OtherTypeConversion_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("[int]'5'");
        var node = ast.FindFirstRequired<ConvertExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_PSObjectStaticProperties_Flags()
    {
        var ast = AstTestHelper.Parse("[PSObject]::Properties");
        var node = ast.FindFirstRequired<MemberExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }
}
