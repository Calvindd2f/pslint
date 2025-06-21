using System;
using System.Collections.Generic;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public static class ReportGenerator
{
    public static LintReport Generate(CodeAnalysisResults results, string? scriptPath, bool isCI)
    {
        var report = new LintReport
        {
            Timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
            ScriptPath = string.IsNullOrEmpty(scriptPath) ? "ScriptBlock Analysis" : scriptPath
        };

        var resultType = typeof(CodeAnalysisResults);
        foreach (var prop in resultType.GetProperties())
        {
            var issues = prop.GetValue(results) as IList<object>;
            if (issues == null || issues.Count == 0)
            {
                continue;
            }

            var categoryName = prop.Name;
            report.Summary.Categories[categoryName] = issues.Count;
            report.Summary.TotalIssues += issues.Count;

            var issueList = new List<LintIssue>();
            foreach (var issue in issues)
            {
                dynamic dynIssue = issue;
                IScriptExtent extent = dynIssue.Extent;
                var suggestion = categoryName switch
                {
                    "OutputSuppression" => "Consider using [void] for performance and clarity instead of piping to Out-Null or assigning to $null.",
                    "ArrayAddition" => "Using += on an array creates a new array and copies all elements on each call. For better performance, use [System.Collections.ArrayList] or [System.Collections.Generic.List[object]] and their .Add() method.",
                    "StringAddition" => "Repeated string concatenation can be inefficient. For complex strings, consider using the -f format operator, -join, or System.Text.StringBuilder.",
                    "LargeFileProcessing" => "For large files, Get-Content can consume a lot of memory. Consider using System.IO.StreamReader for more efficient line-by-line processing.",
                    "LargeCollectionLookup" => "For large collections, PowerShell hashtables can be slower than generic dictionaries. Consider using System.Collections.Generic.Dictionary[TKey, TValue] for better performance.",
                    "WriteHostUsage" => "Write-Host writes directly to the console, which can limit script portability and prevent capturing output. For general output, prefer Write-Output. For logging or debugging, consider Write-Verbose, Write-Debug, or a dedicated logging framework.",
                    "LargeLoops" => "Very large loops can be slow. Consider optimizing the logic inside the loop or exploring faster, array-based operations with .NET methods where possible.",
                    "RepeatedFunctionCalls" => "Calling the same function repeatedly with the same parameters can be inefficient. Consider caching the results in a variable.",
                    "CmdletPipelineWrapping" => extent.Text.Contains("Get-WmiObject") ? "`Get-WmiObject` is obsolete. Use `Get-CimInstance` instead. Also, try to use a `-Filter` parameter instead of piping to `Where-Object` to improve performance by filtering at the source." : "Piping to `Where-Object` can be inefficient for large datasets. Where possible, use a cmdlet-specific `-Filter` parameter to filter results at the source. Long pipelines can also be harder to read and debug.",
                    "DynamicObjectCreation" => "Creating custom objects with `[PSCustomObject]` or `Add-Member` inside loops can be slow. For performance-critical scenarios, consider defining a class.",
                    _ => "Review for potential optimization."
                };

                issueList.Add(new LintIssue
                {
                    Line = extent.StartLineNumber,
                    Text = extent.Text.Trim(),
                    Suggestion = suggestion
                });
            }

            report.Details[categoryName] = issueList;
        }

        if (isCI)
        {
            foreach (var (category, list) in report.Details)
            {
                foreach (var issue in list)
                {
                    Console.WriteLine($"::warning file={report.ScriptPath},line={issue.Line}::[{category}] {issue.Suggestion}");
                }
            }

            // In CI, only summary is returned, similar to PowerShell version
            return report;
        }
        else
        {
            Console.WriteLine();
            Console.WriteLine("=== PowerShell Performance Analysis Report ===");
            Console.WriteLine($"Script: {report.ScriptPath}");
            Console.WriteLine($"Time: {report.Timestamp}");
            Console.WriteLine();
            Console.WriteLine("Summary:");
            Console.WriteLine($"Total Issues Found: {report.Summary.TotalIssues}");

            foreach (var (category, list) in report.Details)
            {
                var count = report.Summary.Categories[category];
                if (count <= 0)
                    continue;

                Console.WriteLine();
                Console.WriteLine($"== {category} ({count} issues) ==");
                foreach (var issue in list)
                {
                    Console.WriteLine($"  Line {issue.Line}:");
                    Console.WriteLine($"    Code: {issue.Text}");
                    Console.WriteLine($"    Suggestion: {issue.Suggestion}");
                }
            }
        }

        GC.Collect();
        GC.WaitForPendingFinalizers();

        return report;
    }
}
