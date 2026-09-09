using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class LargeFileProcessingRuleTests
{
    private readonly LargeFileProcessingRule _rule = new();

    [Fact]
    public void Analyze_GetContentCommand_Flags()
    {
        var ast = AstTestHelper.Parse("Get-Content -Path 'file.txt'");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL004", finding.RuleId);
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
    public void Analyze_FileReadLines_Flags()
    {
        var ast = AstTestHelper.Parse("[File]::ReadLines('file.txt')");
        var node = ast.FindFirstRequired<InvokeMemberExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }

    [Fact]
    public void Analyze_FileReadAllText_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("[File]::ReadAllText('file.txt')");
        var node = ast.FindFirstRequired<InvokeMemberExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_StreamReaderTypeExpression_Flags()
    {
        var ast = AstTestHelper.Parse("[StreamReader]::new('file.txt')");
        var node = ast.FindFirstRequired<TypeExpressionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Single(findings);
    }
}
