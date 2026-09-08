using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>
/// Walks the AST once and, at each node, fans out to every registered rule that opted into that
/// node type. Adding a rule never requires touching this class - it just needs to implement the
/// relevant I*Rule interface and be added to RuleRegistry.
/// </summary>
internal class RuleDispatchVisitor : AstVisitor2
{
    private readonly RuleContext _context;
    private readonly List<IAssignmentStatementRule> _assignmentStatementRules;
    private readonly List<ICommandRule> _commandRules;
    private readonly List<ICommandExpressionRule> _commandExpressionRules;
    private readonly List<IPipelineRule> _pipelineRules;
    private readonly List<IInvokeMemberExpressionRule> _invokeMemberExpressionRules;
    private readonly List<IBinaryExpressionRule> _binaryExpressionRules;
    private readonly List<IExpandableStringExpressionRule> _expandableStringExpressionRules;
    private readonly List<ITypeExpressionRule> _typeExpressionRules;
    private readonly List<IParameterRule> _parameterRules;
    private readonly List<IHashtableRule> _hashtableRules;
    private readonly List<ILoopBodyRule> _loopBodyRules;
    private readonly List<IFunctionDefinitionRule> _functionDefinitionRules;
    private readonly List<IConvertExpressionRule> _convertExpressionRules;
    private readonly List<IMemberExpressionRule> _memberExpressionRules;

    public RuleDispatchVisitor(IEnumerable<IRule> rules, RuleContext context)
    {
        _context = context;
        var ruleList = rules.ToList();

        _assignmentStatementRules = ruleList.OfType<IAssignmentStatementRule>().ToList();
        _commandRules = ruleList.OfType<ICommandRule>().ToList();
        _commandExpressionRules = ruleList.OfType<ICommandExpressionRule>().ToList();
        _pipelineRules = ruleList.OfType<IPipelineRule>().ToList();
        _invokeMemberExpressionRules = ruleList.OfType<IInvokeMemberExpressionRule>().ToList();
        _binaryExpressionRules = ruleList.OfType<IBinaryExpressionRule>().ToList();
        _expandableStringExpressionRules = ruleList.OfType<IExpandableStringExpressionRule>().ToList();
        _typeExpressionRules = ruleList.OfType<ITypeExpressionRule>().ToList();
        _parameterRules = ruleList.OfType<IParameterRule>().ToList();
        _hashtableRules = ruleList.OfType<IHashtableRule>().ToList();
        _loopBodyRules = ruleList.OfType<ILoopBodyRule>().ToList();
        _functionDefinitionRules = ruleList.OfType<IFunctionDefinitionRule>().ToList();
        _convertExpressionRules = ruleList.OfType<IConvertExpressionRule>().ToList();
        _memberExpressionRules = ruleList.OfType<IMemberExpressionRule>().ToList();
    }

    public override AstVisitAction VisitAssignmentStatement(AssignmentStatementAst assignmentStatementAst)
    {
        foreach (var rule in _assignmentStatementRules) rule.Analyze(assignmentStatementAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommand(CommandAst commandAst)
    {
        foreach (var rule in _commandRules) rule.Analyze(commandAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommandExpression(CommandExpressionAst commandExpressionAst)
    {
        foreach (var rule in _commandExpressionRules) rule.Analyze(commandExpressionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitPipeline(PipelineAst pipelineAst)
    {
        foreach (var rule in _pipelineRules) rule.Analyze(pipelineAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitInvokeMemberExpression(InvokeMemberExpressionAst invokeMemberExpressionAst)
    {
        foreach (var rule in _invokeMemberExpressionRules) rule.Analyze(invokeMemberExpressionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitBinaryExpression(BinaryExpressionAst binaryExpressionAst)
    {
        foreach (var rule in _binaryExpressionRules) rule.Analyze(binaryExpressionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitExpandableStringExpression(ExpandableStringExpressionAst expandableStringExpressionAst)
    {
        foreach (var rule in _expandableStringExpressionRules) rule.Analyze(expandableStringExpressionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitTypeExpression(TypeExpressionAst typeExpressionAst)
    {
        foreach (var rule in _typeExpressionRules) rule.Analyze(typeExpressionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitParameter(ParameterAst parameterAst)
    {
        foreach (var rule in _parameterRules) rule.Analyze(parameterAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitHashtable(HashtableAst hashtableAst)
    {
        foreach (var rule in _hashtableRules) rule.Analyze(hashtableAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitForStatement(ForStatementAst forStatementAst)
    {
        foreach (var rule in _loopBodyRules) rule.Analyze(forStatementAst, forStatementAst.Body, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitWhileStatement(WhileStatementAst whileStatementAst)
    {
        foreach (var rule in _loopBodyRules) rule.Analyze(whileStatementAst, whileStatementAst.Body, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitDoWhileStatement(DoWhileStatementAst doWhileStatementAst)
    {
        foreach (var rule in _loopBodyRules) rule.Analyze(doWhileStatementAst, doWhileStatementAst.Body, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitForEachStatement(ForEachStatementAst forEachStatementAst)
    {
        foreach (var rule in _loopBodyRules) rule.Analyze(forEachStatementAst, forEachStatementAst.Body, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitFunctionDefinition(FunctionDefinitionAst functionDefinitionAst)
    {
        foreach (var rule in _functionDefinitionRules) rule.Analyze(functionDefinitionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitConvertExpression(ConvertExpressionAst convertExpressionAst)
    {
        foreach (var rule in _convertExpressionRules) rule.Analyze(convertExpressionAst, _context);
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitMemberExpression(MemberExpressionAst memberExpressionAst)
    {
        foreach (var rule in _memberExpressionRules) rule.Analyze(memberExpressionAst, _context);
        return AstVisitAction.Continue;
    }
}
