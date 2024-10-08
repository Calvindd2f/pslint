Function Get-CommandInfo
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
            File Name	: Get-CommandInfo
            Version     : 1.0

        .LINK
    #>

    [cmdletbinding()]
    [OutputType([System.Management.Automation.CommandInfo])]
    Param (
        [Parameter(Mandatory = $True, position = 0, ParameterSetName = 'ScriptBlock')]
        [System.Management.Automation.ScriptBlock]$ScriptBlock
    )
    try
    {
        $CommandToProcess = Get-CommandToExecute -ScriptBlock $ScriptBlock -First
        switch ($CommandToProcess.gettype().name)
        {
            StringConstantExpressionAst
            {
                if ($CommandToProcess.StringConstantType -eq 'Bareword')
                {
                    $CommandInfo = Get-Command -Name $CommandToProcess.value -ErrorAction Ignore
                    if ($CommandInfo)
                    {
                        return $CommandInfo
                    }
                }
            }
            Default { return $null }
        }
    }
    catch
    {
        Write-Debug $_.Exception -Tags @('CommandInfoError')
        return $null
    }
}