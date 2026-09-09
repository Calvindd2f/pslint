using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class CmdletPipelineWrappingRuleTests
{
    private readonly CmdletPipelineWrappingRule _rule = new();

    [Fact]
    public void Analyze_GetWmiObjectCommand_FlagsWithWmiSuggestion()
    {
        var ast = AstTestHelper.Parse("Get-WmiObject -Class Win32_Process");
        var node = ast.FindFirstRequired<CommandAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL009", finding.RuleId);
        Assert.Contains("Get-CimInstance", finding.Suggestion);
    }

    [Fact]
    public void Analyze_ShortPipeline_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse("Get-Process | Select-Object Name");
        var node = ast.FindFirstRequired<PipelineAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_LongPipelineWithoutWmi_FlagsWithGenericSuggestion()
    {
        var ast = AstTestHelper.Parse("Get-Process | Where-Object { $_.CPU -gt 10 } | Select-Object Name");
        var node = ast.FindFirstRequired<PipelineAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.DoesNotContain("Get-CimInstance", finding.Suggestion);
    }

    [Fact]
    public void Analyze_LongPipelineWithWmi_FlagsWithWmiSuggestion()
    {
        var ast = AstTestHelper.Parse("Get-WmiObject -Class Win32_Process | Where-Object { $_.Name } | Select-Object Name");
        var node = ast.FindFirstRequired<PipelineAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Contains("Get-CimInstance", finding.Suggestion);
    }
}
