#region Parser Errors
Invoke-ScriptAnalyzer -ScriptDefinition '"b" = "b"; function eliminate-file () { }'

<#
    RuleName            Severity   ScriptName Line Message
    --------            --------   ---------- ---- -------
    InvalidLeftHandSide ParseError            1    The assignment expression isn't
                                                valid. The input to an
                                                assignment operator must be an
                                                object that's able to accept
                                                assignments, such as a variable
                                                or a property.
    PSUseApprovedVerbs  Warning               1    The cmdlet 'eliminate-file' uses an
                                                unapproved verb.
    #>

$invokeScriptAnalyzerSplat = @{
    ScriptDefinition = '"b" = "b"; function eliminate-file () { }'
    Severity         = 'Warning'
}
Invoke-ScriptAnalyzer @invokeScriptAnalyzerSplat
#endregion

#region SuppressingRules
function SuppressMe()
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideCommentHelp', '',
        Justification = 'Just an example')]
    param()

    Write-Verbose -Message "I'm making a difference!"

}

function SuppressTwoVariables()
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideDefaultParameterValue', 'b')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideDefaultParameterValue', 'a')]
    param([string]$a, [int]$b)
    {
    }
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideCommentHelp', '', Scope = 'Function')]
param()

function InternalFunction
{
    param()

    Write-Verbose -Message 'I am invincible!'
}

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
    Scope = 'Function', Target = 'start-ba[rz]')]
param()
function start-foo
{
    Write-Host 'start-foo'
}

function start-bar
{
    Write-Host 'start-bar'
}

function start-baz
{
    Write-Host 'start-baz'
}

function start-bam
{
    Write-Host 'start-bam'
}


#To suppress violations in all of the functions:
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
    Scope = 'Function', Target = '*')]
Param()

# To suppress violations in start-bar, start-baz and start-bam but not in start-foo:

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '',
    Scope = 'Function', Target = 'start-b*')]
Param()
#endregion

#region Settings Support
##Built-in Presets
Invoke-ScriptAnalyzer -Path /path/to/module/ -Settings PSGallery -Recurse

##Explicit

# PSScriptAnalyzerSettings.psd1
@{
    Severity     = @('Error', 'Warning')
    ExcludeRules = @('PSAvoidUsingCmdletAliases', 'PSAvoidUsingWriteHost')
}
Invoke-ScriptAnalyzer -Path MyScript.ps1 -Settings PSScriptAnalyzerSettings.psd1

# PSScriptAnalyzerSettings.psd1
@{
    IncludeRules = @('PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingConvertToSecureStringWithPlainText')
}
Invoke-ScriptAnalyzer -Path MyScript.ps1 -Settings PSScriptAnalyzerSettings.psd1

## Implicit
Invoke-ScriptAnalyzer -Path 'C:\path\to\project' -Recurse
#endregion


#region Custom rules

##The module must export the custom rule functions using Export-ModuleMember for them to be available to PSScriptAnalyzer.

##In this example the property CustomRulePath points to two different modules. Both modules export the rule functions with the verb Measure so Measure-* is used for the property IncludeRules.



@{
    CustomRulePath = @(
        '.\output\RequiredModules\DscResource.AnalyzerRules'
        '.\tests\QA\AnalyzerRules\SqlServerDsc.AnalyzerRules.psm1'
    )

    IncludeRules   = @(
        'Measure-*'
    )
}


#property IncludeDefaultRules to $true
@{
    CustomRulePath      = @(
        '.\output\RequiredModules\DscResource.AnalyzerRules'
        '.\tests\QA\AnalyzerRules\SqlServerDsc.AnalyzerRules.psm1'
    )

    IncludeDefaultRules = $true

    IncludeRules        = @(
        # Default rules
        'PSAvoidDefaultValueForMandatoryParameter'
        'PSAvoidDefaultValueSwitchParameter'

        # Custom rules
        'Measure-*'
    )
}
#endregion

# Using custom rules in Visual Studio Code (.vscode/settings.json).
{
    'powershell.scriptAnalysis.settingsPath': '.vscode/analyzersettings.psd1',
    'powershell.scriptAnalysis.enable': true
}

# ScriptAnalyzer as a .NET library
$script:scriptanalyzerdotnetlib = @'
using Microsoft.Windows.PowerShell.ScriptAnalyzer

public void Initialize(System.Management.Automation.Runspaces.Runspace runspace,
    Microsoft.Windows.PowerShell.ScriptAnalyzer.IOutputWriter outputWriter,
    [string[] customizedRulePath = null],
    [string[] includeRuleNames = null],
    [string[] excludeRuleNames = null],
    [string[] severity = null],
    [bool suppressedOnly = false],
    [string profile = null])

public System.Collections.Generic.IEnumerable<DiagnosticRecord> AnalyzePath(string path,
    [bool searchRecursively = false])

public System.Collections.Generic.IEnumerable<IRule> GetRule(string[] moduleNames,
    string[] ruleNames)
'@
