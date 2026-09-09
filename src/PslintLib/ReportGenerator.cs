using System;
using System.Collections.Generic;
using System.Linq;

namespace PslintLib.Analysis;

public static class ReportGenerator
{
    private static readonly Dictionary<string, int> CategoryOrder = RuleRegistry.AllRules
        .Select((rule, index) => (rule.Category, index))
        .GroupBy(x => x.Category)
        .ToDictionary(g => g.Key, g => g.First().index);

    public static LintReport Generate(CodeAnalysisResults results, string? scriptPath, bool isCI)
    {
        var report = new LintReport
        {
            Timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
            ScriptPath = string.IsNullOrEmpty(scriptPath) ? "ScriptBlock Analysis" : scriptPath
        };

        var groups = results.Findings
            .GroupBy(f => f.Category)
            .OrderBy(g => CategoryOrder.TryGetValue(g.Key, out var order) ? order : int.MaxValue);

        foreach (var group in groups)
        {
            var categoryName = group.Key;

            var issueList = group
                .Select(finding => new LintIssue
                {
                    RuleId = finding.RuleId,
                    Severity = finding.Severity.ToString(),
                    Line = finding.Extent?.StartLineNumber ?? 0,
                    Text = finding.Extent?.Text?.Trim() ?? "Unknown",
                    Suggestion = finding.Suggestion
                })
                .ToList();

            report.Summary.Categories[categoryName] = issueList.Count;
            report.Summary.TotalIssues += issueList.Count;
            report.Details[categoryName] = issueList;
        }

        if (isCI)
        {
            foreach (var kvp in report.Details)
            {
                var category = kvp.Key;
                foreach (var issue in kvp.Value)
                {
                    var annotationType = issue.Severity == nameof(Severity.Error) ? "error" : "warning";
                    Console.WriteLine($"::{annotationType} file={report.ScriptPath},line={issue.Line}::[{category}][{issue.RuleId}] {issue.Suggestion}");
                }
            }
        }

        GC.Collect();
        GC.WaitForPendingFinalizers();

        return report;
    }
}
