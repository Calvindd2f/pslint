using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests.Rules;

public class LargeCollectionLookupRuleTests
{
    private readonly LargeCollectionLookupRule _rule = new();

    private static string BuildHashtable(int entryCount)
    {
        var entries = Enumerable.Range(1, entryCount).Select(i => $"'key{i}' = {i}");
        return "@{" + string.Join("; ", entries) + "}";
    }

    [Fact]
    public void Analyze_HashtableWithMoreThanTenEntries_Flags()
    {
        var ast = AstTestHelper.Parse(BuildHashtable(12));
        var node = ast.FindFirstRequired<HashtableAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        var finding = Assert.Single(findings);
        Assert.Equal("PSL005", finding.RuleId);
    }

    [Fact]
    public void Analyze_HashtableWithTenOrFewerEntries_DoesNotFlag()
    {
        var ast = AstTestHelper.Parse(BuildHashtable(6));
        var node = ast.FindFirstRequired<HashtableAst>();
        var findings = new List<Finding>();

        _rule.Analyze(node, new RuleContext(findings));

        Assert.Empty(findings);
    }
}
