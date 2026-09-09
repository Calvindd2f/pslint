using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace PslintLib.Analysis;

// Minimal subset of the SARIF 2.1.0 object model needed to describe pslint findings -
// https://docs.oasis-open.org/sarif/sarif/v2.1.0/. Hand-rolled rather than pulling in the
// official SDK so the shipped module keeps its narrow dependency footprint (see CHANGELOG
// v2.2.0 "Dependency Isolation"). Property names below are PascalCase C# and rely on a
// camelCase JsonNamingPolicy at serialization time to match the spec's casing; "$schema" is
// the one property camelCasing can't produce, so it carries an explicit JsonPropertyName.

public class SarifLog
{
    [JsonPropertyName("$schema")]
    public string Schema { get; set; } = "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json";

    public string Version { get; set; } = "2.1.0";

    public List<SarifRun> Runs { get; set; } = new();
}

public class SarifRun
{
    public SarifTool Tool { get; set; } = new();

    public List<SarifResult> Results { get; set; } = new();
}

public class SarifTool
{
    public SarifToolDriver Driver { get; set; } = new();
}

public class SarifToolDriver
{
    public string Name { get; set; } = "pslint";

    public string? InformationUri { get; set; }

    public string? Version { get; set; }

    public List<SarifReportingDescriptor> Rules { get; set; } = new();
}

public class SarifReportingDescriptor
{
    public string Id { get; set; } = string.Empty;

    public SarifMessage? ShortDescription { get; set; }

    public SarifMessage? FullDescription { get; set; }

    public SarifReportingConfiguration? DefaultConfiguration { get; set; }
}

public class SarifReportingConfiguration
{
    public string Level { get; set; } = "warning";
}

public class SarifMessage
{
    public string Text { get; set; } = string.Empty;
}

public class SarifResult
{
    public string RuleId { get; set; } = string.Empty;

    public int RuleIndex { get; set; }

    public string Level { get; set; } = "warning";

    public SarifMessage Message { get; set; } = new();

    public List<SarifLocation> Locations { get; set; } = new();
}

public class SarifLocation
{
    public SarifPhysicalLocation PhysicalLocation { get; set; } = new();
}

public class SarifPhysicalLocation
{
    public SarifArtifactLocation ArtifactLocation { get; set; } = new();

    public SarifRegion? Region { get; set; }
}

public class SarifArtifactLocation
{
    public string Uri { get; set; } = string.Empty;
}

public class SarifRegion
{
    public int StartLine { get; set; }

    public int StartColumn { get; set; }

    public int EndLine { get; set; }

    public int EndColumn { get; set; }

    public SarifMessage? Snippet { get; set; }
}
