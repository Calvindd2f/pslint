using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class RepeatedFunctionCallsRuleTests
{
    private readonly RepeatedFunctionCallsRule _rule = new();

    [Fact]
    public void Analyze_FunctionWithCStyleForLoop_Flags()
    {
        var ast = AstTestHelper.Parse(@"
function Test-Thing {
    for ($i = 0; $i -lt 10; $i++) { Write-Output $i }
}");
        var node = ast.FindFirstRequired<FunctionDefinitionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL008", finding.RuleId);
    }

    [Fact]
    public void Analyze_FunctionWithForeachLoop_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(@"
function Test-Thing {
    foreach ($i in 1..10) { Write-Output $i }
}");
        var node = ast.FindFirstRequired<FunctionDefinitionAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
