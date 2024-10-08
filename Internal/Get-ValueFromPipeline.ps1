Function Get-ValueFromPipeline
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
            File Name	: Get-ValueFromPipeline
            Version     : 1.0

        .LINK
    #>

    [cmdletbinding()]
    [OutputType([System.Boolean])]
    Param (
        [Parameter(Mandatory = $True, position = 0, ParameterSetName = 'ScriptBlock')]
        [System.Management.Automation.ScriptBlock]$ScriptBlock
    )
    try
    {
        $query = '$Ast -is [System.Management.Automation.Language.NamedAttributeArgumentAst] -and $Ast.ArgumentName -eq "ValueFromPipeline" -and [bool]$Ast.Argument.Extent.Text -eq $true'
        $ValueFromPipeline = Get-ElementFromAst -ScriptBlock $ScriptBlock -Query $query
        if ($ValueFromPipeline)
        {
            return $True
        }
        else
        {
            return $false
        }
    }
    catch
    {
        Write-Information $_ -Tags @('ValueFromPipeline')
        return $false
    }
}