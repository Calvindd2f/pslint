using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>Orchestrates a single-pass rule-based analysis of an AST and collects the findings.</summary>
public static class RuleEngine
{
    public static CodeAnalysisResults Analyze(Ast ast, bool isManifest)
    {
        var findings = new List<Finding>();
        var context = new RuleContext(findings);

        var visitor = new RuleDispatchVisitor(RuleRegistry.AllRules, context);
        ast.Visit(visitor);

        foreach (var rule in RuleRegistry.AllRules.OfType<IWholeAstRule>())
        {
            rule.Analyze(ast, isManifest, context);
        }

        return new CodeAnalysisResults(findings);
    }
}
