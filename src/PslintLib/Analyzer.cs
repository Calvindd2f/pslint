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

    /// <summary>
    /// Parses and analyzes a raw source string directly. Used for the -Fix path, which needs a
    /// guarantee that Finding.Node's extent offsets are relative to exactly the string it is about
    /// to slice and rewrite. That guarantee does not hold for ScriptBlock.Ast in every case - an
    /// inline scriptblock literal passed as a cmdlet argument can carry extents offset against the
    /// whole enclosing command line rather than against ScriptBlock.ToString() alone - so -Fix
    /// re-parses fresh from the exact text it is editing instead of reusing an existing AST.
    /// </summary>
    public static CodeAnalysisResults AnalyzeText(string text, bool isManifest = false)
    {
        var ast = Parser.ParseInput(text, out Token[] tokens, out ParseError[] errors);
        if (errors.Length > 0)
        {
            var errorMessages = string.Join(Environment.NewLine, System.Linq.Enumerable.Select(errors, e => $"[Line {e.Extent.StartLineNumber}, Column {e.Extent.StartColumnNumber}] {e.Message}"));
            throw new InvalidOperationException($"Parse errors encountered:{Environment.NewLine}{errorMessages}");
        }

        return AnalyzeAst(ast, isManifest);
    }

    private static CodeAnalysisResults AnalyzeAst(Ast ast, bool isManifest)
    {
        return RuleEngine.Analyze(ast, isManifest);
    }
}
