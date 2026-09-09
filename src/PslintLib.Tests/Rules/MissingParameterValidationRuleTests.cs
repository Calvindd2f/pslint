using System.Collections.Generic;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class MissingParameterValidationRuleTests
{
    private readonly MissingParameterValidationRule _rule = new();

    private static ParameterAst ParseFirstParameter(string paramDeclaration)
    {
        var ast = AstTestHelper.Parse($@"
function Get-Thing {{
    param(
        {paramDeclaration}
        $Name
    )
    $Name
}}");
        return ast.FindFirstRequired<ParameterAst>();
    }

    [Fact]
    public void Analyze_MandatoryUntypedUnvalidated_Flags()
    {
        var node = ParseFirstParameter("[Parameter(Mandatory = $true)]");
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL014", finding.RuleId);
    }

    [Fact]
    public void Analyze_MandatoryWithTypeConstraint_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(@"
function Get-Thing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    $Name
}");
        var node = ast.FindFirstRequired<ParameterAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_MandatoryWithValidationAttribute_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(@"
function Get-Thing {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Name
    )
    $Name
}");
        var node = ast.FindFirstRequired<ParameterAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_ExplicitlyNotMandatory_DoesNotFlag()
    {
        var node = ParseFirstParameter("[Parameter(Mandatory = $false)]");
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }

    [Fact]
    public void Analyze_NoParameterAttributeAtAll_DoesNotFlag()
    {
        var node = ParseFirstParameter("");
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
