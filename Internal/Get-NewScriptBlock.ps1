Function Get-NewScriptBlock
{
    <#
        .SYNOPSIS

        .DESCRIPTION

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
            Author		: @Calvindd2f
            Site		: https://app-support.com
            File Name	: Get-NewScriptBlock
            Version     : 1.0

        .LINK
    #>

    [cmdletbinding()]
    [OutputType([System.Management.Automation.ScriptBlock])]
    Param (
        [Parameter(Mandatory = $True, position = 0, ParameterSetName = 'CommandInfo')]
        [System.Management.Automation.CommandInfo]$CommandInfo
    )
    try
    {
        $MetaData = [System.Management.Automation.CommandMetadata]::New($CommandInfo)
        #$CmdletBinding = [System.Management.Automation.ProxyCommand]::GetCmdletBindingAttribute($Metadata)
        $Paramblock = [System.Management.Automation.ProxyCommand]::GetParamBlock($Metadata)
        if ([string]::IsNullOrEmpty($Paramblock))
        {
            Write-Information ("{0} does not use any parameters. Trying to find function within scriptblock" -f $commandInfo.Name)
            $PathExists = Test-Path -Path $CommandInfo.Source -PathType Leaf
            if ($PathExists)
            {
                $tokens = $errors = $null
                $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                    $CommandInfo.Source,
                    [ref]$tokens,
                    [ref]$errors
                )
                $fnc = $ast.Find({
                        param([System.Management.Automation.Language.Ast] $Ast)

                        $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                        # Class methods have a FunctionDefinitionAst under them as well, but we don't want them.
                            ($PSVersionTable.PSVersion.Major -lt 5 -or
                        $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])

                    }, $true)
                if ($fnc)
                {
                    $PScript = $fnc.Body.GetScriptBlock()
                }
            }
        }
        else
        {
            #Remove the body of the actual function and replace it with the custom code to return the Parameters used.
            $PScript = [System.Management.Automation.ProxyCommand]::Create($MetaData)
            #$PScript = [scriptblock]::Create($PScript)
            $parsed = [System.Management.Automation.Language.Parser]::ParseInput($PScript, [ref]$null, [ref]$null)
            if ($null -ne $parsed)
            {
                $PScript = $parsed.GetScriptBlock()
            }
        }
        return $PScript
    }
    catch
    {
        Write-Error $_
    }
}