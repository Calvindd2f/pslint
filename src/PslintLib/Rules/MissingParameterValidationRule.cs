using System;
using System.Management.Automation.Language;

namespace PslintLib.Analysis;

/// <summary>PSL014: a mandatory parameter with no type constraint and no [Validate*] attribute.</summary>
public sealed class MissingParameterValidationRule : IParameterRule
{
    public string Id => "PSL014";
    public string Name => "Missing Parameter Validation";
    public string Category => "MissingParameterValidation";
    public Severity Severity => Severity.Warning;
    public string DefaultSuggestion =>
        "This mandatory parameter has no type constraint or [Validate*] attribute. Add one (e.g. [string], [ValidateNotNullOrEmpty()]) so invalid input is rejected at the function boundary instead of failing later with a less obvious error.";

    public void Analyze(ParameterAst ast, RuleContext context)
    {
        bool isMandatory = false;
        bool hasTypeConstraint = false;
        bool hasValidationAttribute = false;

        foreach (var attribute in ast.Attributes)
        {
            if (attribute is TypeConstraintAst)
            {
                hasTypeConstraint = true;
                continue;
            }

            if (attribute is AttributeAst attributeAst)
            {
                if (string.Equals(attributeAst.TypeName.Name, "Parameter", StringComparison.OrdinalIgnoreCase))
                {
                    foreach (var namedArgument in attributeAst.NamedArguments)
                    {
                        if (string.Equals(namedArgument.ArgumentName, "Mandatory", StringComparison.OrdinalIgnoreCase))
                        {
                            if (namedArgument.ExpressionOmitted)
                            {
                                isMandatory = true;
                            }
                            else if (namedArgument.Argument is VariableExpressionAst boolVar &&
                                      string.Equals(boolVar.VariablePath.UserPath, "false", StringComparison.OrdinalIgnoreCase))
                            {
                                isMandatory = false;
                            }
                            else
                            {
                                isMandatory = true;
                            }
                        }
                    }
                }
                else if (attributeAst.TypeName.Name.StartsWith("Validate", StringComparison.OrdinalIgnoreCase))
                {
                    hasValidationAttribute = true;
                }
            }
        }

        if (isMandatory && !hasTypeConstraint && !hasValidationAttribute)
        {
            context.Report(this, ast);
        }
    }
}
