using System.Linq;
using PslintLib.Analysis;
using Xunit;

namespace PslintLib.Tests;

public class RuleRegistryTests
{
    [Fact]
    public void AllRules_HaveUniqueNonEmptyIds()
    {
        var ids = RuleRegistry.AllRules.Select(r => r.Id).ToList();

        Assert.All(ids, id => Assert.False(string.IsNullOrWhiteSpace(id)));
        Assert.Equal(ids.Count, ids.Distinct().Count());
    }

    [Fact]
    public void AllRules_HaveNonEmptyCategoryAndSuggestion()
    {
        foreach (var rule in RuleRegistry.AllRules)
        {
            Assert.False(string.IsNullOrWhiteSpace(rule.Category));
            Assert.False(string.IsNullOrWhiteSpace(rule.Name));
            Assert.False(string.IsNullOrWhiteSpace(rule.DefaultSuggestion));
        }
    }

    [Fact]
    public void AllRules_MatchesFullCatalog()
    {
        // Pins the catalog size so a rule silently dropped from RuleRegistry (but still present
        // as a class) fails loudly here instead of just quietly stopping firing.
        Assert.Equal(15, RuleRegistry.AllRules.Count);
    }
}
