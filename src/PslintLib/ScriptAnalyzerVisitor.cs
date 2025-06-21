using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public class ScriptAnalyzerVisitor : AstVisitor2
{
    public CodeAnalysisResults Results { get; } = new();

    public override AstVisitAction VisitAssignmentStatement(AssignmentStatementAst assignmentStatementAst)
    {
        // TODO: implement analysis logic
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommand(CommandAst commandAst)
    {
        // TODO: implement analysis logic
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitCommandExpression(CommandExpressionAst commandExpressionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitPipeline(PipelineAst pipelineAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitInvokeMemberExpression(InvokeMemberExpressionAst invokeMemberExpressionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitBinaryExpression(BinaryExpressionAst binaryExpressionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitExpandableStringExpression(ExpandableStringExpressionAst expandableStringExpressionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitTypeExpression(TypeExpressionAst typeExpressionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitHashtable(HashtableAst hashtableAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitForStatement(ForStatementAst forStatementAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitWhileStatement(WhileStatementAst whileStatementAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitDoWhileStatement(DoWhileStatementAst doWhileStatementAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitForEachStatement(ForEachStatementAst forEachStatementAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitFunctionDefinition(FunctionDefinitionAst functionDefinitionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitConvertExpression(ConvertExpressionAst convertExpressionAst)
    {
        return AstVisitAction.Continue;
    }

    public override AstVisitAction VisitMemberExpression(MemberExpressionAst memberExpressionAst)
    {
        return AstVisitAction.Continue;
    }
}
