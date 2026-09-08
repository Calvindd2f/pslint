using System.Collections.Generic;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>
/// Relative importance of a rule finding. Drives CI annotation type (::error vs ::warning)
/// and is intended for future config-driven filtering (e.g. "fail build on Error findings only").
/// </summary>
public enum Severity
{
    Info,
    Warning,
    Error
}

/// <summary>
/// Base contract every rule implements. A rule declares its own identity; detection is opted into
/// via one of the node-specific interfaces below (IAssignmentStatementRule, ICommandRule, etc.),
/// which RuleDispatchVisitor fans AST nodes out to.
/// </summary>
public interface IRule
{
    /// <summary>Stable identifier shown in reports, e.g. "PSL001". Never renumber a shipped rule.</summary>
    string Id { get; }

    /// <summary>Short human-readable name, e.g. "Array Addition in Loop".</summary>
    string Name { get; }

    /// <summary>
    /// Report grouping key. Kept equal to the pre-refactor CodeAnalysisResults property names
    /// (e.g. "ArrayAddition") so JSON/CSV output shape is unchanged for existing consumers.
    /// </summary>
    string Category { get; }

    Severity Severity { get; }

    /// <summary>Suggestion text used when a rule reports a finding without an override.</summary>
    string DefaultSuggestion { get; }
}

public interface IAssignmentStatementRule : IRule
{
    void Analyze(AssignmentStatementAst ast, RuleContext context);
}

public interface ICommandRule : IRule
{
    void Analyze(CommandAst ast, RuleContext context);
}

public interface ICommandExpressionRule : IRule
{
    void Analyze(CommandExpressionAst ast, RuleContext context);
}

public interface IPipelineRule : IRule
{
    void Analyze(PipelineAst ast, RuleContext context);
}

public interface IInvokeMemberExpressionRule : IRule
{
    void Analyze(InvokeMemberExpressionAst ast, RuleContext context);
}

public interface IBinaryExpressionRule : IRule
{
    void Analyze(BinaryExpressionAst ast, RuleContext context);
}

public interface IExpandableStringExpressionRule : IRule
{
    void Analyze(ExpandableStringExpressionAst ast, RuleContext context);
}

public interface ITypeExpressionRule : IRule
{
    void Analyze(TypeExpressionAst ast, RuleContext context);
}

public interface IParameterRule : IRule
{
    void Analyze(ParameterAst ast, RuleContext context);
}

public interface IHashtableRule : IRule
{
    void Analyze(HashtableAst ast, RuleContext context);
}

/// <summary>Dispatched once per for/while/do-while/foreach loop with its body statement block.</summary>
public interface ILoopBodyRule : IRule
{
    void Analyze(Ast loopAst, StatementBlockAst body, RuleContext context);
}

public interface IFunctionDefinitionRule : IRule
{
    void Analyze(FunctionDefinitionAst ast, RuleContext context);
}

public interface IConvertExpressionRule : IRule
{
    void Analyze(ConvertExpressionAst ast, RuleContext context);
}

public interface IMemberExpressionRule : IRule
{
    void Analyze(MemberExpressionAst ast, RuleContext context);
}

/// <summary>
/// Dispatched once per analyzed file/script block against the whole AST, after node-by-node
/// traversal completes. Used by rules that need cross-tree reasoning (duplicate detection) or
/// only apply to a specific file kind (module manifest efficiency).
/// </summary>
public interface IWholeAstRule : IRule
{
    void Analyze(Ast root, bool isManifest, RuleContext context);
}

/// <summary>A single reported issue, produced by a rule via RuleContext.Report.</summary>
public class Finding
{
    public string RuleId { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public Severity Severity { get; set; }
    public IScriptExtent? Extent { get; set; }
    public string Suggestion { get; set; } = string.Empty;
}

/// <summary>
/// Passed to every rule's Analyze call. Rules report findings through this rather than mutating
/// shared state directly, keeping each rule self-contained and independently testable.
/// </summary>
public class RuleContext
{
    private readonly List<Finding> _findings;

    public RuleContext(List<Finding> findings)
    {
        _findings = findings;
    }

    public void Report(IRule rule, Ast node, string? suggestion = null)
    {
        _findings.Add(new Finding
        {
            RuleId = rule.Id,
            Category = rule.Category,
            Severity = rule.Severity,
            Extent = node.Extent,
            Suggestion = suggestion ?? rule.DefaultSuggestion
        });
    }
}
