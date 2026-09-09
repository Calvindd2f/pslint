using System.Collections.Generic;

namespace PslintLib.Analysis;

public class CodeAnalysisResults
{
    public List<Finding> Findings { get; }

    public CodeAnalysisResults(List<Finding> findings)
    {
        Findings = findings;
    }
}
