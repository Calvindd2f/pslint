using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL012: module manifest exports left as wildcard/`$null` instead of an explicit list, which slows module discovery.</summary>
public sealed class ManifestEfficiencyRule : IWholeAstRule
{
    private static readonly string[] KeysToCheck = { "FunctionsToExport", "CmdletsToExport", "AliasesToExport" };

    public string Id => "PSL012";
    public string Name => "Manifest Export Efficiency";
    public string Category => "ManifestEfficiency";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion =>
        "In module manifests, avoid using wildcards ('*') or omitting entries like CmdletsToExport, FunctionsToExport, and AliasesToExport. Use an empty array '@()' to explicitly indicate nothing is exported. This dramatically improves module loading performance by preventing slow CDXML scanning.";

    public void Analyze(Ast root, bool isManifest, RuleContext context)
    {
        if (!isManifest)
        {
            return;
        }

        var manifestAst = root.FindAll(a => a is HashtableAst, true).FirstOrDefault();
        if (manifestAst is not HashtableAst hashtableAst)
        {
            return;
        }

        var foundKeys = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        foreach (var kvp in hashtableAst.KeyValuePairs)
        {
            if (kvp.Item1 is not StringConstantExpressionAst stringKey)
            {
                continue;
            }

            var keyName = stringKey.Value;
            if (!KeysToCheck.Contains(keyName, StringComparer.OrdinalIgnoreCase))
            {
                continue;
            }

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
                context.Report(this, kvp.Item1);
            }
        }

        foreach (var key in KeysToCheck)
        {
            if (!foundKeys.Contains(key))
            {
                context.Report(this, hashtableAst);
            }
        }
    }
}
