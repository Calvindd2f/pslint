using System.Management.Automation;
using System.Linq;

namespace PslintLib;

[Cmdlet(VerbsLifecycle.Invoke, "Pslint", DefaultParameterSetName = "Path")]
[Alias("Scan-PowerShellScriptAdvanced", "pslint")]
public class InvokePslintCommand : PSCmdlet
{
    [Parameter(ParameterSetName = "Path", Position = 0, ValueFromPipelineByPropertyName = true)]
    public string Path { get; set; } = string.Empty;

    [Parameter(ParameterSetName = "ScriptBlock", Position = 0)]
    public ScriptBlock? ScriptBlock { get; set; }

    [Parameter]
    [ValidateSet("stdout", "textonly", "JSON", "CSV", IgnoreCase = true)]
    public string OutputFormat { get; set; } = "stdout";

    [Parameter]
    public string OutputPath { get; set; } = string.Empty;

    [Parameter]
    public SwitchParameter QueuePSSA { get; set; }

    [Parameter]
    public string PSSAConfig { get; set; } = string.Empty;

    protected override void BeginProcessing()
    {
        if (ParameterSetName == "Path")
        {
            if (string.IsNullOrWhiteSpace(Path))
            {
                var moduleName = this.MyInvocation.MyCommand.Module?.Name ?? "pslint";
                var moduleAuthor = this.MyInvocation.MyCommand.Module?.Author ?? "Calvin Bergin <Calvindd2f>";
                var moduleVersion = this.MyInvocation.MyCommand.Module?.Version?.ToString() ?? "2.1.0";
                
                Host.UI.WriteLine($"{moduleName} v{moduleVersion} by {moduleAuthor}");
                Host.UI.WriteLine("Please define input path:");
                Path = Host.UI.ReadLine()?.Trim() ?? string.Empty;
                
                if (string.IsNullOrWhiteSpace(Path))
                {
                    ThrowTerminatingError(new ErrorRecord(
                        new System.ArgumentException("Path cannot be empty."),
                        "EmptyPath",
                        ErrorCategory.InvalidArgument,
                        null
                    ));
                }
            }
            
            if (!System.Text.RegularExpressions.Regex.IsMatch(Path, "(?i)\\.(ps1|psm1|psd1)$"))
            {
                ThrowTerminatingError(new ErrorRecord(
                    new System.ArgumentException("Path must point to a .ps1, .psm1, or .psd1 file."),
                    "InvalidExtension",
                    ErrorCategory.InvalidArgument,
                    Path
                ));
            }

            if (!System.IO.File.Exists(Path))
            {
                ThrowTerminatingError(new ErrorRecord(
                    new System.IO.FileNotFoundException("File not found", Path),
                    "FileNotFound",
                    ErrorCategory.ObjectNotFound,
                    Path
                ));
            }
        }
        else
        {
            if (ScriptBlock == null)
            {
                ThrowTerminatingError(new ErrorRecord(
                    new System.ArgumentNullException(nameof(ScriptBlock)),
                    "NullScriptBlock",
                    ErrorCategory.InvalidArgument,
                    null
                ));
            }
        }
    }

    protected override void ProcessRecord()
    {
        Analysis.CodeAnalysisResults results;

        if (ParameterSetName == "Path")
        {
            results = Analysis.Analyzer.AnalyzeFile(Path);
        }
        else
        {
            results = Analysis.Analyzer.AnalyzeScriptBlock(ScriptBlock!);
        }

        bool isCi = false;
        var ciEnv = System.Environment.GetEnvironmentVariable("CI");
        if (!string.IsNullOrEmpty(ciEnv) && bool.TryParse(ciEnv, out bool parsedCi))
        {
            isCi = parsedCi;
        }

        var report = Analysis.ReportGenerator.Generate(results, ParameterSetName == "Path" ? Path : null, isCi);
        
        string formattedOutput = string.Empty;

        switch (OutputFormat.ToLowerInvariant())
        {
            case "json":
                using (var ps = System.Management.Automation.PowerShell.Create(RunspaceMode.CurrentRunspace))
                {
                    ps.AddCommand("ConvertTo-Json").AddParameter("InputObject", report).AddParameter("Depth", 5);
                    var jsonResult = ps.Invoke();
                    if (jsonResult.Count > 0)
                    {
                        formattedOutput = string.Join(System.Environment.NewLine, jsonResult.Select(r => r.ToString()));
                    }
                }
                break;
            case "csv":
                var csvLines = new System.Collections.Generic.List<string> { "Category,Line,Text,Suggestion" };
                foreach (var kvp in report.Details)
                {
                    foreach (var issue in kvp.Value)
                    {
                        var text = issue.Text?.Replace("\"", "\"\"") ?? "";
                        var suggestion = issue.Suggestion?.Replace("\"", "\"\"") ?? "";
                        csvLines.Add($"\"{kvp.Key}\",\"{issue.Line}\",\"{text}\",\"{suggestion}\"");
                    }
                }
                formattedOutput = string.Join(System.Environment.NewLine, csvLines);
                break;
            case "stdout":
            case "textonly":
                var sb = new System.Text.StringBuilder();
                sb.AppendLine("Script: " + report.ScriptPath);
                sb.AppendLine("Time: " + report.Timestamp);
                sb.AppendLine("Summary:");
                sb.AppendLine("Total Issues Found: " + report.Summary.TotalIssues);
                
                foreach (var kvp in report.Details)
                {
                    if (report.Summary.Categories.TryGetValue(kvp.Key, out int count) && count > 0)
                    {
                        sb.AppendLine($"{kvp.Key}_{count}");
                    }
                }
                
                if (OutputFormat.ToLowerInvariant() == "textonly")
                {
                    sb.AppendLine();
                    foreach (var kvp in report.Details)
                    {
                        if (report.Summary.Categories.TryGetValue(kvp.Key, out int count) && count > 0)
                        {
                            sb.AppendLine($"== {kvp.Key} ({count} issues) ==");
                            foreach (var issue in kvp.Value)
                            {
                                sb.AppendLine($"  Line {issue.Line}:");
                                sb.AppendLine($"    Code: {issue.Text}");
                                sb.AppendLine($"    Suggestion: {issue.Suggestion}");
                            }
                            sb.AppendLine();
                        }
                    }
                }
                formattedOutput = sb.ToString();
                
                if (OutputFormat.ToLowerInvariant() == "stdout")
                {
                    Host.UI.WriteLine(formattedOutput);
                }
                break;
        }

        if (!string.IsNullOrWhiteSpace(OutputPath))
        {
            var outPath = this.SessionState.Path.GetUnresolvedProviderPathFromPSPath(OutputPath);
            if (System.IO.Directory.Exists(outPath))
            {
                var ext = OutputFormat.ToLowerInvariant() == "json" ? "json" : 
                          (OutputFormat.ToLowerInvariant() == "csv" ? "csv" : "txt");
                outPath = System.IO.Path.Combine(outPath, $"pslint_report_{System.DateTime.Now:yyyyMMdd_HHmmss}.{ext}");
            }
            System.IO.File.WriteAllText(outPath, formattedOutput);
        }
        else if (OutputFormat.ToLowerInvariant() != "stdout")
        {
            WriteObject(formattedOutput);
        }

        if (OutputFormat.ToLowerInvariant() == "stdout")
        {
            WriteObject(report);
        }

        if (QueuePSSA)
        {
            using (var ps = System.Management.Automation.PowerShell.Create(RunspaceMode.CurrentRunspace))
            {
                // Check if ScriptAnalyzer is installed
                ps.AddCommand("Get-Module").AddParameter("ListAvailable").AddParameter("Name", "PSScriptAnalyzer");
                var modules = ps.Invoke();
                ps.Commands.Clear();

                if (modules.Count == 0)
                {
                    Host.UI.WriteLine("PSScriptAnalyzer is not installed. Installing from PSGallery...");
                    ps.AddCommand("Install-Module")
                      .AddParameter("Name", "PSScriptAnalyzer")
                      .AddParameter("Force", true)
                      .AddParameter("Scope", "CurrentUser");
                    ps.Invoke();
                    ps.Commands.Clear();
                }

                ps.AddCommand("Invoke-ScriptAnalyzer");
                if (ParameterSetName == "Path")
                {
                    ps.AddParameter("Path", Path);
                }
                else
                {
                    ps.AddParameter("ScriptDefinition", ScriptBlock!.ToString());
                }

                if (!string.IsNullOrWhiteSpace(PSSAConfig))
                {
                    var configPath = this.SessionState.Path.GetUnresolvedProviderPathFromPSPath(PSSAConfig);
                    ps.AddParameter("Settings", configPath);
                }

                var pssaResults = ps.Invoke();
                
                if (ps.HadErrors)
                {
                    foreach (var err in ps.Streams.Error)
                    {
                        WriteError(err);
                    }
                }
                
                foreach (var res in pssaResults)
                {
                    WriteObject(res);
                }
            }
        }
    }
}
