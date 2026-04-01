using System.Management.Automation;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace PslintLib;

[Cmdlet(VerbsLifecycle.Invoke, "Pslint", DefaultParameterSetName = "Path")]
[Alias("Scan-PowerShellScriptAdvanced", "pslint")]
public class InvokePslintCommand : PSCmdlet
{
    [Parameter(Mandatory = true, ParameterSetName = "Path", Position = 0, ValueFromPipelineByPropertyName = true)]
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

    // New BenchmarkMode parameters
    [Parameter]
    public SwitchParameter BenchmarkMode { get; set; }

    [Parameter]
    public string BenchmarkModeFileBefore { get; set; } = string.Empty;

    [Parameter]
    public string BenchmarkModeFileAfter { get; set; } = string.Empty;

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
        // Closes ProcessRecord
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
