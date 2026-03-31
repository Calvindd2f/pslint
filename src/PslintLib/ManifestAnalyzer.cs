using System;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public static class ManifestAnalyzer
{
    public static void Analyze(HashtableAst hashtableAst, CodeAnalysisResults results)
    {
        var keysToCheck = new[] { "FunctionsToExport", "CmdletsToExport", "AliasesToExport" };
        var foundKeys = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var kvp in hashtableAst.KeyValuePairs)
        {
            if (kvp.Item1 is StringConstantExpressionAst stringKey)
            {
                var keyName = stringKey.Value;
                if (keysToCheck.Contains(keyName, StringComparer.OrdinalIgnoreCase))
                {
                    foundKeys.Add(keyName);
                    
                    bool hasWildcard = false;
                    bool isNull = false;



                    var strVal = kvp.Item2.Find(a => a is StringConstantExpressionAst, true) as StringConstantExpressionAst;
                    if (strVal != null && strVal.Value == "*")
                    {
                        hasWildcard = true;
                    }
                    
                    var arrayAst = kvp.Item2.Find(a => a is ArrayLiteralAst, true) as ArrayLiteralAst;
                    if (arrayAst != null)
                    {
                        foreach (var elem in arrayAst.Elements)
                        {
                            if (elem is StringConstantExpressionAst arrStr && arrStr.Value.Contains("*"))
                            {
                                hasWildcard = true;
                            }
                        }
                    }
                    
                    var varAst = kvp.Item2.Find(a => a is VariableExpressionAst, true) as VariableExpressionAst;
                    if (varAst != null && string.Equals(varAst.VariablePath.UserPath, "null", StringComparison.OrdinalIgnoreCase))
                    {
                        isNull = true;
                    }

                    if (hasWildcard || isNull)
                    {
                        results.ManifestEfficiency.Add(kvp.Item1);
                    }
                }
            }
        }

        foreach (var key in keysToCheck)
        {
            if (!foundKeys.Contains(key))
            {
                // Missing key entirely. Add the hashtable ast as the issue to highlight the whole manifest needs it.
                results.ManifestEfficiency.Add(hashtableAst);
            }
        }
    }
}
