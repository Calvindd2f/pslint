using System.Collections.Generic;

namespace PslintLib.Analysis;

/// <summary>
/// The full set of built-in rules, in catalog order (PSL001..PSL015). This order also fixes the
/// order categories appear in a generated report, independent of AST traversal order.
/// </summary>
public static class RuleRegistry
{
    public static IReadOnlyList<IRule> AllRules { get; } = new List<IRule>
    {
        new ArrayAdditionRule(),
        new StringAdditionRule(),
        new OutputSuppressionRule(),
        new LargeFileProcessingRule(),
        new LargeCollectionLookupRule(),
        new WriteHostUsageRule(),
        new LargeLoopsRule(),
        new RepeatedFunctionCallsRule(),
        new CmdletPipelineWrappingRule(),
        new DynamicObjectCreationRule(),
        new ParallelExecutionRule(),
        new ManifestEfficiencyRule(),
        new MissingErrorHandlingRule(),
        new MissingParameterValidationRule(),
        new DuplicatedCodeBlocksRule(),
    };
}
