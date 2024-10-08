Function Get-CommandToExecute
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
            File Name	: Get-CommandToExecute
            Version     : 1.0

        .LINK
    #>

    [cmdletbinding()]
    [OutputType([System.Management.Automation.Language.StringConstantExpressionAst])]
    Param (
        [Parameter(Mandatory = $True, ParameterSetName = 'ScriptBlock')]
        [System.Management.Automation.ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [Switch]$First
    )
    try
    {
        $query = '$Ast -is [System.Management.Automation.Language.CommandAst]'
        $CommandAsts = Get-ElementFromAst -ScriptBlock $ScriptBlock -Query $query
        #$CommandAsts = $scriptblock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]} , $true)
        if ($First)
        {
            #Get first command to process
            $CommandToProcess = $CommandAsts.CommandElements | Select-Object -First 1
        }
        else
        {
            $CommandToProcess = $CommandAsts.CommandElements
        }
        return $CommandToProcess
    }
    catch
    {
        Write-Information $_ -Tags @('CommandToProcessError')
        return $null
    }
}