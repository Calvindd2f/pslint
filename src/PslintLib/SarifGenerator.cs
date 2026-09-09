using System.Collections.Generic;
using System.Linq;

namespace PslintLib.Analysis;

public static class SarifGenerator
{
    private const string ProjectUri = "https://github.com/calvindd2f/pslint";

    private static readonly Dictionary<string, int> RuleIndexById = RuleRegistry.AllRules
        .Select((rule, index) => (rule.Id, index))
        .ToDictionary(x => x.Id, x => x.index);

    public static SarifLog Generate(CodeAnalysisResults results, string? scriptPath)
    {
        var artifactUri = ToArtifactUri(scriptPath);

        var log = new SarifLog();
        var run = new SarifRun
        {
            Tool = new SarifTool
            {
                Driver = new SarifToolDriver
                {
                    Name = "pslint",
                    InformationUri = ProjectUri,
                    Rules = RuleRegistry.AllRules.Select(rule => new SarifReportingDescriptor
                    {
                        Id = rule.Id,
                        ShortDescription = new SarifMessage { Text = rule.Name },
                        FullDescription = new SarifMessage { Text = rule.DefaultSuggestion },
                        DefaultConfiguration = new SarifReportingConfiguration { Level = ToSarifLevel(rule.Severity) }
                    }).ToList()
                }
            }
        };

        foreach (var finding in results.Findings)
        {
            var result = new SarifResult
            {
                RuleId = finding.RuleId,
                RuleIndex = RuleIndexById.TryGetValue(finding.RuleId, out var index) ? index : -1,
                Level = ToSarifLevel(finding.Severity),
                Message = new SarifMessage { Text = finding.Suggestion }
            };

            var extent = finding.Extent;
            var physicalLocation = new SarifPhysicalLocation
            {
                ArtifactLocation = new SarifArtifactLocation { Uri = artifactUri }
            };

            if (extent != null)
            {
                physicalLocation.Region = new SarifRegion
                {
                    StartLine = extent.StartLineNumber,
                    StartColumn = extent.StartColumnNumber,
                    EndLine = extent.EndLineNumber,
                    EndColumn = extent.EndColumnNumber,
                    Snippet = new SarifMessage { Text = extent.Text?.Trim() ?? string.Empty }
                };
            }

            result.Locations.Add(new SarifLocation { PhysicalLocation = physicalLocation });
            run.Results.Add(result);
        }

        log.Runs.Add(run);
        return log;
    }

    private static string ToSarifLevel(Severity severity) => severity switch
    {
        Severity.Error => "error",
        Severity.Warning => "warning",
        Severity.Info => "note",
        _ => "warning"
    };

    private static string ToArtifactUri(string? scriptPath)
    {
        return string.IsNullOrEmpty(scriptPath) ? "ScriptBlock" : scriptPath!.Replace('\\', '/');
    }
}
