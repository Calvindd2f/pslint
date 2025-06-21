using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public class IssueDetail
{
    public int Line { get; set; }
    public string Text { get; set; } = string.Empty;
    public string Suggestion { get; set; } = string.Empty;
}

public class ReportSummary
{
    public int TotalIssues { get; set; }
    public Dictionary<string, int> Categories { get; } = new();
}

public class Report
{
    public ReportSummary Summary { get; } = new();
    public Dictionary<string, List<IssueDetail>> Details { get; } = new();
    public string Timestamp { get; set; } = string.Empty;
    public string ScriptPath { get; set; } = string.Empty;
}

public static class ReportGenerator
{
    public static Report Generate(CodeAnalysisResults results, string? path)
    {
        var report = new Report
        {
            Timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"),
            ScriptPath = string.IsNullOrEmpty(path) ? "ScriptBlock Analysis" : path
        };

        var properties = typeof(CodeAnalysisResults).GetProperties();
        foreach (var property in properties)
        {
            if (property.PropertyType.IsGenericType &&
                property.PropertyType.GetGenericTypeDefinition() == typeof(List<>))
            {
                var issues = property.GetValue(results) as System.Collections.IList;
                if (issues == null || issues.Count == 0)
                {
                    continue;
                }

                var categoryName = property.Name;
                report.Summary.Categories[categoryName] = issues.Count;
                report.Summary.TotalIssues += issues.Count;

                var detailList = new List<IssueDetail>();
                foreach (var issueObj in issues)
                {
                    int line = 0;
                    string text = string.Empty;

                    if (issueObj is Ast ast)
                    {
                        line = ast.Extent.StartLineNumber;
                        text = ast.Extent.Text.Trim();
                    }

                    detailList.Add(new IssueDetail
                    {
                        Line = line,
                        Text = text,
                        Suggestion = GetSuggestion(categoryName, text)
                    });
                }

                report.Details[categoryName] = detailList;
            }
        }

        return report;
    }

    private static string GetSuggestion(string categoryName, string text)
    {
        return categoryName switch
        {
            "OutputSuppression" => "Consider using [void] for performance and clarity instead of piping to Out-Null or assigning to $null.",
            "ArrayAddition" => "Using += on an array creates a new array and copies all elements on each call. For better performance, use System.Collections.ArrayList or System.Collections.Generic.List[object] and their .Add() method.",
            "StringAddition" => "Repeated string concatenation can be inefficient. For complex strings, consider using the -f format operator, -join, or System.Text.StringBuilder.",
            "LargeFileProcessing" => "For large files, Get-Content can consume a lot of memory. Consider using System.IO.StreamReader for more efficient line-by-line processing.",
            "LargeCollectionLookup" => "For large collections, PowerShell hashtables can be slower than generic dictionaries. Consider using System.Collections.Generic.Dictionary[TKey, TValue] for better performance.",
            "WriteHostUsage" => "Write-Host writes directly to the console, which can limit script portability and prevent capturing output. For general output, prefer Write-Output. For logging or debugging, consider Write-Verbose, Write-Debug, or a dedicated logging framework.",
            "LargeLoops" => "Very large loops can be slow. Consider optimizing the logic inside the loop or exploring faster, array-based operations with .NET methods where possible.",
            "RepeatedFunctionCalls" => "Calling the same function repeatedly with the same parameters can be inefficient. Consider caching the results in a variable.",
            "CmdletPipelineWrapping" => text.Contains("Get-WmiObject")
                ? "`Get-WmiObject` is obsolete. Use `Get-CimInstance` instead. Also, try to use a -Filter parameter instead of piping to Where-Object to improve performance by filtering at the source."
                : "Piping to Where-Object can be inefficient for large datasets. Where possible, use a cmdlet-specific -Filter parameter to filter results at the source. Long pipelines can also be harder to read and debug.",
            "DynamicObjectCreation" => "Creating custom objects with [PSCustomObject] or Add-Member inside loops can be slow. For performance-critical scenarios, consider defining a class.",
            _ => "Review for potential optimization."
        };
    }
}
