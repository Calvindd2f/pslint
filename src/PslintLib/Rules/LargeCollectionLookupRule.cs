using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL005: a hashtable literal large enough that a typed Dictionary would look up faster.</summary>
public sealed class LargeCollectionLookupRule : IHashtableRule
{
    public string Id => "PSL005";
    public string Name => "Large Collection Lookup";
    public string Category => "LargeCollectionLookup";
    public Severity Severity => Severity.Info;
    public string DefaultSuggestion =>
        "For large collections, PowerShell hashtables can be slower than generic dictionaries. Consider using System.Collections.Generic.Dictionary[TKey, TValue] for better performance.";

    public void Analyze(HashtableAst ast, RuleContext context)
    {
        if (ast.KeyValuePairs.Count > 10)
        {
            context.Report(this, ast);
        }
    }
}
