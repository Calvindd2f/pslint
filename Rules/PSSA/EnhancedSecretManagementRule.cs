//EnhancedSecretManagementRule.cs
using System;
using System.Collections.Generic;
using System.Management.Automation.Language;
using Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace CustomScriptAnalyzerRules
{
    public class EnhancedSecretManagementRule : IScriptRule
    {
        public RuleInfo GetRuleInfo()
        {
            return new RuleInfo(
                name: "EnhancedSecretManagementRule",
                commonName: "Enhanced detection of insecure secret management practices",
                description: "Detects various insecure practices related to secret management in PowerShell scripts, including in comments.",
                severity: RuleSeverity.Warning,
                sourceType: SourceType.Builtin,
                errorCategory: ErrorCategory.Security
            );
        }

        public IEnumerable<DiagnosticRecord> AnalyzeScript(Ast ast, string fileName)
        {
            if (ast == null) yield break;

            var visitor = new EnhancedSecretManagementVisitor();
            ast.Visit(visitor);

            foreach (var diagnostic in visitor.Diagnostics)
            {
                yield return diagnostic;
            }
        }

        private class EnhancedSecretManagementVisitor : AstVisitor
        {
            private readonly HashSet<string> _sensitiveKeywords = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "secret", "apikey", "key", "token", "appsecret", "appkey",
                "username", "password", "user", "pass", "pwd", "creds",
                "credentials", "credz", "login", "client_secret"
            };

            public List<DiagnosticRecord> Diagnostics { get; } = new List<DiagnosticRecord>();

            public override AstVisitAction VisitAssignmentStatement(AssignmentStatementAst assignmentStatementAst)
            {
                var variableName = assignmentStatementAst.Left.GetVariablePath().UserPath;

                // Check for sensitive variable initialization
                if (_sensitiveKeywords.Contains(variableName))
                {
                    if (!(assignmentStatementAst.Right is VariableExpressionAst rightVar) ||
                        !rightVar.VariablePath.UserPath.Equals("env", StringComparison.OrdinalIgnoreCase))
                    {
                        AddDiagnostic(assignmentStatementAst, "Avoid initializing potentially sensitive information in variable '{0}'. Consider using secure methods like PowerShell Secret Management or Azure Key Vault.", variableName);
                    }
                }

                // Check for ConvertFrom-SecureString usage
                if (IsConvertFromSecureStringInvocation(assignmentStatementAst.Right))
                {
                    AddDiagnostic(assignmentStatementAst, "Usage of ConvertFrom-SecureString detected. This may expose sensitive information. Ensure this is used securely.");
                }

                return AstVisitAction.Continue;
            }

            public override AstVisitAction VisitCommandAst(CommandAst commandAst)
            {
                // Check for ConvertTo-SecureString usage without Read-Host
                if (IsConvertToSecureStringWithoutReadHost(commandAst))
                {
                    AddDiagnostic(commandAst, "Usage of ConvertTo-SecureString without Read-Host detected. This may indicate hardcoded secrets.");
                }

                // Check for potentially insecure Read-Host usage
                if (IsInsecureReadHostUsage(commandAst))
                {
                    AddDiagnostic(commandAst, "Potentially insecure usage of Read-Host detected. Ensure sensitive information is not exposed.");
                }

                return AstVisitAction.Continue;
            }

            public override AstVisitAction VisitInvokeMemberExpression(InvokeMemberExpressionAst invokeMemberExpressionAst)
            {
                // Check for [Net.NetworkCredential]::new('', $password).Password
                if (IsNetworkCredentialPasswordAccess(invokeMemberExpressionAst))
                {
                    AddDiagnostic(invokeMemberExpressionAst, "Accessing plain text password from NetworkCredential object detected. This may expose sensitive information.");
                }

                // Check for Marshal.SecureStringToBSTR and PtrToStringBSTR usage
                if (IsMarshalSecureStringConversion(invokeMemberExpressionAst))
                {
                    AddDiagnostic(invokeMemberExpressionAst, "Converting SecureString to plain text detected. This may expose sensitive information.");
                }

                return AstVisitAction.Continue;
            }

            public override AstVisitAction VisitScriptBlockAst(ScriptBlockAst scriptBlockAst)
            {
                CheckCommentsForSensitiveInfo(scriptBlockAst);
                return AstVisitAction.Continue;
            }

            private void CheckCommentsForSensitiveInfo(ScriptBlockAst scriptBlockAst)
            {
                var tokens = scriptBlockAst.EndBlock.Extent.GetPSCodeTokens();
                foreach (var token in tokens)
                {
                    if (token.Kind == TokenKind.Comment)
                    {
                        CheckCommentForSensitiveInfo(token);
                    }
                }
            }

            private void CheckCommentForSensitiveInfo(Token token)
            {
                string commentText = token.Text.TrimStart('#', '<').TrimEnd('>').Trim();

                // Check for single-line comment pattern
                foreach (var keyword in _sensitiveKeywords)
                {
                    if (Regex.IsMatch(commentText, $@"\b{keyword}\s*:\s*\S+", RegexOptions.IgnoreCase))
                    {
                        AddDiagnostic(token, "Potential sensitive information found in comment: {0}", keyword);
                        break;
                    }
                }

                // Check for multi-line comment pattern
                if (commentText.Contains("Credentials") ||
                    _sensitiveKeywords.Any(keyword => commentText.Contains(keyword, StringComparison.OrdinalIgnoreCase)))
                {
                    AddDiagnostic(token, "Potential sensitive information found in multi-line comment");
                }
            }

            private bool IsConvertFromSecureStringInvocation(ExpressionAst expressionAst)
            {
                return expressionAst is CommandAst commandAst &&
                       commandAst.GetCommandName().Equals("ConvertFrom-SecureString", StringComparison.OrdinalIgnoreCase);
            }

            private bool IsConvertToSecureStringWithoutReadHost(CommandAst commandAst)
            {
                return commandAst.GetCommandName().Equals("ConvertTo-SecureString", StringComparison.OrdinalIgnoreCase) &&
                       !commandAst.Pipeline.Extent.Text.Contains("Read-Host");
            }

            private bool IsInsecureReadHostUsage(CommandAst commandAst)
            {
                if (commandAst.GetCommandName().Equals("Read-Host", StringComparison.OrdinalIgnoreCase))
                {
                    return !commandAst.Parameters.Any(p => p.ParameterName.Equals("AsSecureString", StringComparison.OrdinalIgnoreCase));
                }
                return false;
            }

            private bool IsNetworkCredentialPasswordAccess(InvokeMemberExpressionAst invokeMemberExpressionAst)
            {
                return invokeMemberExpressionAst.Expression.Extent.Text.Contains("[Net.NetworkCredential]") &&
                       invokeMemberExpressionAst.Member.Extent.Text.Equals("Password", StringComparison.OrdinalIgnoreCase);
            }

            private bool IsMarshalSecureStringConversion(InvokeMemberExpressionAst invokeMemberExpressionAst)
            {
                var methodName = invokeMemberExpressionAst.Member.Extent.Text;
                return invokeMemberExpressionAst.Expression.Extent.Text.Contains("[Runtime.InteropServices.Marshal]") &&
                       (methodName.Equals("SecureStringToBSTR", StringComparison.OrdinalIgnoreCase) ||
                        methodName.Equals("PtrToStringBSTR", StringComparison.OrdinalIgnoreCase));
            }

            private void AddDiagnostic(IScriptExtent extent, string message, params object[] args)
            {
                Diagnostics.Add(new DiagnosticRecord(
                    message: string.Format(message, args),
                    extent: extent,
                    ruleName: "EnhancedSecretManagementRule",
                    severity: RuleSeverity.Warning,
                    ruleId: "ESM1000"
                ));
            }
        }
    }
}