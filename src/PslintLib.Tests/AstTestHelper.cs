using System;
using System.Linq;
using System.Management.Automation.Language;

namespace PslintLib.Tests;

/// <summary>
/// Parses small PowerShell snippets into real ASTs so rule tests exercise the same
/// System.Management.Automation.Language types the analyzer sees in production, rather than
/// hand-built fakes.
/// </summary>
internal static class AstTestHelper
{
    public static Ast Parse(string script)
    {
        var ast = Parser.ParseInput(script, out _, out ParseError[] errors);
        if (errors.Length > 0)
        {
            throw new InvalidOperationException(
                $"Test snippet failed to parse: {string.Join("; ", errors.Select(e => e.Message))}\nScript:\n{script}");
        }
        return ast;
    }

    /// <summary>Finds the first descendant of type T, or null if none exists.</summary>
    public static T? FindFirst<T>(this Ast root) where T : Ast
    {
        return root.Find(a => a is T, true) as T;
    }

    /// <summary>Finds the first descendant of type T, failing the test if none is found.</summary>
    public static T FindFirstRequired<T>(this Ast root) where T : Ast
    {
        return root.FindFirst<T>()
            ?? throw new InvalidOperationException($"Expected to find a {typeof(T).Name} in parsed snippet, but found none.");
    }
}
