using System.Management.Automation;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace PslintLib;

[Cmdlet(VerbsLifecycle.Invoke, "Pslint", DefaultParameterSetName = "Path", SupportsShouldProcess = true)]
[Alias("Scan-PowerShellScriptAdvanced", "pslint")]
public class InvokePslintCommand : PSCmdlet
{
    [Parameter(Mandatory = true, ParameterSetName = "Path", Position = 0, ValueFromPipelineByPropertyName = true)]
    public string Path { get; set; } = string.Empty;

    [Parameter(ParameterSetName = "ScriptBlock", Position = 0)]
    public ScriptBlock? ScriptBlock { get; set; }

    [Parameter]
    [ValidateSet("stdout", "textonly", "JSON", "CSV", "SARIF", IgnoreCase = true)]
    public string OutputFormat { get; set; } = "stdout";

    [Parameter]
    public string OutputPath { get; set; } = string.Empty;

    [Parameter]
    public SwitchParameter QueuePSSA { get; set; }

    [Parameter]
    public string PSSAConfig { get; set; } = string.Empty;

    // New BenchmarkMode parameters
    [Parameter]
    public SwitchParameter BenchmarkMode { get; set; }

    [Parameter]
    public string BenchmarkModeFileBefore { get; set; } = string.Empty;

    [Parameter]
    public string BenchmarkModeFileAfter { get; set; } = string.Empty;

    /// <summary>
    /// Applies the safe, mechanical fixes available for whatever was found (see IFixableRule
    /// implementations - currently a deliberately small set: Out-Null/&gt;$null output suppression
    /// and missing -ThrottleLimit on ForEach-Object -Parallel). In -Path mode this rewrites the
    /// file in place and honors -WhatIf/-Confirm; in -ScriptBlock mode there's no file to write
    /// back to, so the fixed script text is returned instead.
    /// </summary>
    [Parameter]
    public SwitchParameter Fix { get; set; }

    protected override void BeginProcessing()
    {
        if (ParameterSetName == "Path")
        {
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

        // Run benchmarks before analysis if BenchmarkMode is enabled
        List<string> benchmarkOutputs = null;
        if (BenchmarkMode.IsPresent)
        {
            var scripts = GetBenchmarkScripts();
            if (scripts != null && scripts.Any())
            {
                var task = RunBenchmarksAsync(scripts);
                while (!task.IsCompleted)
                {
                    System.Threading.Thread.Sleep(50);
                }
                benchmarkOutputs = task.GetAwaiter().GetResult();
                // Output benchmark results
                foreach (var outStr in benchmarkOutputs)
                {
                    Host.UI.WriteLine("--- Benchmark Output ---");
                    Host.UI.WriteLine(outStr);
                }
            }
        }

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
                formattedOutput = System.Text.Json.JsonSerializer.Serialize(report, new System.Text.Json.JsonSerializerOptions { WriteIndented = true });
                break;
            case "csv":
                var csvLines = new System.Collections.Generic.List<string> { "Category,RuleId,Severity,Line,Text,Suggestion" };
                foreach (var kvp in report.Details)
                {
                    foreach (var issue in kvp.Value)
                    {
                        var text = issue.Text?.Replace("\"", "\"\"") ?? "";
                        var suggestion = issue.Suggestion?.Replace("\"", "\"\"") ?? "";
                        csvLines.Add($"\"{kvp.Key}\",\"{issue.RuleId}\",\"{issue.Severity}\",\"{issue.Line}\",\"{text}\",\"{suggestion}\"");
                    }
                }
                formattedOutput = string.Join(System.Environment.NewLine, csvLines);
                break;
            case "sarif":
                var sarifLog = Analysis.SarifGenerator.Generate(results, ParameterSetName == "Path" ? Path : null);
                formattedOutput = System.Text.Json.JsonSerializer.Serialize(sarifLog, new System.Text.Json.JsonSerializerOptions
                {
                    WriteIndented = true,
                    PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase
                });
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
                                sb.AppendLine($"  Line {issue.Line} [{issue.RuleId}] ({issue.Severity}):");
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
                var ext = OutputFormat.ToLowerInvariant() switch
                {
                    "json" => "json",
                    "csv" => "csv",
                    "sarif" => "sarif",
                    _ => "txt"
                };
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
                    ThrowTerminatingError(new ErrorRecord(
                        new System.InvalidOperationException("PSScriptAnalyzer is required but not installed. Please install it with 'Install-Module PSScriptAnalyzer'."),
                        "PSScriptAnalyzerMissing",
                        ErrorCategory.ResourceUnavailable,
                        null
                    ));
                    return;
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

        if (Fix.IsPresent)
        {
            ApplyFixes();
        }
        // Closes ProcessRecord
        }

        private void ApplyFixes()
        {
            var sourceText = ParameterSetName == "Path"
                ? System.IO.File.ReadAllText(Path)
                : ScriptBlock!.ToString();

            // Re-parse fresh from sourceText rather than reusing the `results` computed earlier
            // for the report: those findings' Node extents may be offset against a different
            // buffer (e.g. a ScriptBlock literal's Ast can be offset against the whole enclosing
            // command line), which would corrupt the fix if used to slice sourceText directly.
            var isManifest = ParameterSetName == "Path" &&
                Path.EndsWith(".psd1", System.StringComparison.OrdinalIgnoreCase);
            var fixResults = Analysis.Analyzer.AnalyzeText(sourceText, isManifest);

            var fixes = Analysis.FixEngine.CollectFixes(fixResults, sourceText);
            if (fixes.Count == 0)
            {
                Host.UI.WriteLine("No auto-fixable issues found.");
                return;
            }

            // ApplyFixes can decline an edit that overlaps another one it already applied (e.g.
            // a throttle-limit insertion nested inside a pipeline another fix is rewriting whole).
            // Report on what actually landed in Text, not on what was merely collected above -
            // otherwise the summary can claim a fix was applied when the overlap guard dropped it.
            var applyResult = Analysis.FixEngine.ApplyFixes(sourceText, fixes.Select(f => f.Edit));
            var appliedEdits = new System.Collections.Generic.HashSet<Analysis.TextEdit>(applyResult.Applied);
            var appliedFixes = fixes.Where(f => appliedEdits.Contains(f.Edit)).ToList();

            if (appliedFixes.Count == 0)
            {
                Host.UI.WriteLine($"Found {fixes.Count} potential fix(es), but every one overlapped another and none could be safely applied. Re-run after addressing the overlapping issue by hand.");
                return;
            }

            var summary = string.Join(", ", appliedFixes
                .GroupBy(f => f.Finding.RuleId)
                .OrderBy(g => g.Key)
                .Select(g => $"{g.Key} x{g.Count()}"));
            var fixedText = applyResult.Text;

            if (ParameterSetName == "Path")
            {
                if (ShouldProcess(Path, $"Apply {appliedFixes.Count} auto-fix(es) ({summary})"))
                {
                    System.IO.File.WriteAllText(Path, fixedText);
                    Host.UI.WriteLine($"Applied {appliedFixes.Count} fix(es) to {Path}: {summary}");
                    if (applyResult.Skipped.Count > 0)
                    {
                        Host.UI.WriteLine($"Skipped {applyResult.Skipped.Count} fix(es) that overlapped one already applied. Run pslint -Fix again to pick them up now that the conflicting edit has landed.");
                    }
                }
            }
            else
            {
                Host.UI.WriteLine($"Applied {appliedFixes.Count} fix(es) ({summary}). Returning fixed script text.");
                if (applyResult.Skipped.Count > 0)
                {
                    Host.UI.WriteLine($"Skipped {applyResult.Skipped.Count} fix(es) that overlapped one already applied.");
                }
                WriteObject(fixedText);
            }
        }

        // Helper method to retrieve benchmark script contents
        private IEnumerable<string> GetBenchmarkScripts()
        {
            var scripts = new List<string>();
            if (!string.IsNullOrWhiteSpace(BenchmarkModeFileBefore) && System.IO.File.Exists(BenchmarkModeFileBefore))
                scripts.Add(System.IO.File.ReadAllText(BenchmarkModeFileBefore));
            
            if (!string.IsNullOrWhiteSpace(BenchmarkModeFileAfter) && System.IO.File.Exists(BenchmarkModeFileAfter))
                scripts.Add(System.IO.File.ReadAllText(BenchmarkModeFileAfter));
            
            // If no files provided, return default benchmark scripts from Microsoft docs guidelines
            if (scripts.Count == 0)
            {
                scripts.Add(@"
Write-Output '--- Array Addition Benchmark (+=) ---'
Measure-Command {
    $array = @()
    for ($i = 0; $i -lt 10000; $i++) { $array += $i }
} | Select-Object -ExpandProperty TotalMilliseconds | ForEach-Object { Write-Output ""Array += took $_ ms"" }

Write-Output '--- List<T>.Add Benchmark ---'
Measure-Command {
    $list = [System.Collections.Generic.List[int]]::new()
    for ($i = 0; $i -lt 10000; $i++) { $list.Add($i) }
} | Select-Object -ExpandProperty TotalMilliseconds | ForEach-Object { Write-Output ""List.Add took $_ ms"" }
");
                
                scripts.Add(@"
Write-Output '--- ForEach-Object Pipeline Benchmark ---'
Measure-Command {
    1..10000 | ForEach-Object { $_ }
} | Select-Object -ExpandProperty TotalMilliseconds | ForEach-Object { Write-Output ""ForEach-Object took $_ ms"" }

Write-Output '--- foreach Statement Benchmark ---'
Measure-Command {
    foreach ($i in 1..10000) { $i }
} | Select-Object -ExpandProperty TotalMilliseconds | ForEach-Object { Write-Output ""foreach statement took $_ ms"" }
");
            }
            return scripts;
        }

        // Helper method to run benchmarks asynchronously
        private async Task<List<string>> RunBenchmarksAsync(IEnumerable<string> scriptContents)
        {
            var results = new List<string>();
            var tasks = new List<Task>();
            foreach (var scriptContent in scriptContents)
            {
                tasks.Add(Task.Run(() =>
                {
                    using var ps = System.Management.Automation.PowerShell.Create(RunspaceMode.NewRunspace);
                    ps.AddScript(scriptContent);
                    var output = ps.Invoke();
                    var sb = new System.Text.StringBuilder();
                    foreach (var o in output)
                    {
                        sb.AppendLine(o?.ToString());
                    }
                    lock (results)
                    {
                        results.Add(sb.ToString());
                    }
                }));
            }
            await Task.WhenAll(tasks);
            return results;
        }
    }
