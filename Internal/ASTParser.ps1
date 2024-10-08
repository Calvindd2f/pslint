function Parse-AST
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
            File Name	: Parse-AST
            Version     : 1.0

        .LINK
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$null, [ref]$null)

    $ast
}
