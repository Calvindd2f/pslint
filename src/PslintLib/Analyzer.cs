using System;
using System.Management.Automation;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

public static class Analyzer
{
    public static CodeAnalysisResults AnalyzeFile(string path)
    {
        if (!System.IO.File.Exists(path))
        {
            throw new System.IO.FileNotFoundException("File not found", path);
        }

        var ast = Parser.ParseFile(path, out Token[] tokens, out ParseError[] errors);
        if (errors.Length > 0)
        {
            throw new InvalidOperationException("Parse errors encountered");
        }

        return AnalyzeAst(ast);
    }

    public static CodeAnalysisResults AnalyzeScriptBlock(ScriptBlock scriptBlock)
    {
        if (scriptBlock is null)
        {
            throw new ArgumentNullException(nameof(scriptBlock));
        }

        return AnalyzeAst(scriptBlock.Ast);
    }

    private static CodeAnalysisResults AnalyzeAst(Ast ast)
    {
        var visitor = new ScriptAnalyzerVisitor();
        ast.Visit(visitor);
        return visitor.Results;
    }

    public static CodeAnalysisResults AnalyzeScriptBlock(ScriptBlock scriptBlock)
    {
        if (scriptBlock == null)
        {
            throw new ArgumentNullException(nameof(scriptBlock));
        }

        var visitor = new ScriptAnalyzerVisitor();
        scriptBlock.Ast.Visit(visitor);
        return visitor.Results;
    }
}
