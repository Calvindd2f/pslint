using System;
using System.Collections.Generic;

namespace PslintLib.Analysis;

public class LintIssue
{
    public int Line { get; set; }
    public string Text { get; set; } = string.Empty;
    public string Suggestion { get; set; } = string.Empty;
}

public class LintReportSummary
{
    public int TotalIssues { get; set; }
    public Dictionary<string, int> Categories { get; set; } = new();
}

public class LintReport
{
    public LintReportSummary Summary { get; set; } = new();
    public Dictionary<string, List<LintIssue>> Details { get; set; } = new();
    public string Timestamp { get; set; } = string.Empty;
    public string ScriptPath { get; set; } = string.Empty;
}
