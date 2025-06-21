using System.Collections.Generic;

namespace PslintLib.Analysis;

public class CodeAnalysisResults
{
    public List<object> OutputSuppression { get; } = new();
    public List<object> ArrayAddition { get; } = new();
    public List<object> StringAddition { get; } = new();
    public List<object> LargeFileProcessing { get; } = new();
    public List<object> LargeCollectionLookup { get; } = new();
    public List<object> WriteHostUsage { get; } = new();
    public List<object> LargeLoops { get; } = new();
    public List<object> RepeatedFunctionCalls { get; } = new();
    public List<object> CmdletPipelineWrapping { get; } = new();
    public List<object> DynamicObjectCreation { get; } = new();

    public void Clear()
    {
        OutputSuppression.Clear();
        ArrayAddition.Clear();
        StringAddition.Clear();
        LargeFileProcessing.Clear();
        LargeCollectionLookup.Clear();
        WriteHostUsage.Clear();
        LargeLoops.Clear();
        RepeatedFunctionCalls.Clear();
        CmdletPipelineWrapping.Clear();
        DynamicObjectCreation.Clear();
    }
}
