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
            var errorMessages = string.Join(Environment.NewLine, System.Linq.Enumerable.Select(errors, e => $"[Line {e.Extent.StartLineNumber}, Column {e.Extent.StartColumnNumber}] {e.Message}"));
            throw new InvalidOperationException($"Parse errors encountered in {path}:{Environment.NewLine}{errorMessages}");
        }

        return AnalyzeAst(ast, path.EndsWith(".psd1", StringComparison.OrdinalIgnoreCase));
    }

    public static CodeAnalysisResults AnalyzeScriptBlock(ScriptBlock scriptBlock)
    {
        if (scriptBlock is null)
        {
            throw new ArgumentNullException(nameof(scriptBlock));
        }

        return AnalyzeAst(scriptBlock.Ast, false);
    }

    private static CodeAnalysisResults AnalyzeAst(Ast ast, bool isManifest)
    {
        var visitor = new ScriptAnalyzerVisitor();
        ast.Visit(visitor);
        var results = visitor.Results;

        if (isManifest)
        {
            var pds1Ast = System.Linq.Enumerable.FirstOrDefault(ast.FindAll(a => a is HashtableAst, true));
            if (pds1Ast is HashtableAst hashtableAst)
            {
                ManifestAnalyzer.Analyze(hashtableAst, results);
            }
        }

        return results;
    }
}
