using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>Detection logic shared by more than one rule.</summary>
internal static class RuleHelpers
{
    public static bool IsInsideTryStatement(Ast ast)
    {
        for (Ast child = ast, parent = ast.Parent; parent != null; child = parent, parent = parent.Parent)
        {
            if (parent is TryStatementAst tryStatement && ReferenceEquals(tryStatement.Body, child))
            {
                return true;
            }
        }
        return false;
    }

    /// <summary>
    /// True for a `+=` assignment whose right-hand side is not a plain numeric literal, i.e. the
    /// cases that plausibly grow an array or a string rather than incrementing a counter.
    /// </summary>
    public static bool IsNonNumericPlusEquals(AssignmentStatementAst assignmentStatementAst)
    {
        if (assignmentStatementAst.Operator != TokenKind.PlusEquals)
        {
            return false;
        }

        if (assignmentStatementAst.Right is CommandExpressionAst ceAst && ceAst.Expression is ConstantExpressionAst constAst)
        {
            return !(constAst.Value is int || constAst.Value is double || constAst.Value is decimal);
        }

        return true;
    }
}
