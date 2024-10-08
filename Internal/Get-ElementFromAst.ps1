Function Get-ElementFromAst
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
            File Name	: Get-ElementFromAst
            Version     : 1.0

        .LINK
    #>

    [cmdletbinding()]
    Param (
        [Parameter(Mandatory = $True, ParameterSetName = 'ScriptBlock')]
        [System.Management.Automation.ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $false)]
        [String]$Query,

        [Parameter(Mandatory = $false)]
        [Switch]$Detailed
    )
    Begin
    {
        $all_elements = @()
        if ($Query)
        {
            #$my_query = [ScriptBlock]::Create(('param([System.Management.Automation.Language.Ast] $Ast); {0}' -f $Query))
            #$matchedElements = $ScriptBlock.Ast.FindAll($my_query, $true) | Where-Object { $_ }
            $txt_query = ('param([System.Management.Automation.Language.Ast] $Ast); {0}' -f $Query)
            $my_query = [System.Management.Automation.Language.Parser]::ParseInput($txt_query, [ref]$null, [ref]$null)
            $matchedElements = $ScriptBlock.Ast.FindAll($my_query.GetScriptBlock(), $true) | Where-Object { $_ }
        }
        else
        {
            $matchedElements = $null
        }
    }
    Process
    {
        if ($null -ne $matchedElements)
        {
            if ($Detailed)
            {
                foreach ($element in $matchedElements)
                {
                    [pscustomobject]$match = @{
                        Text       = $element.Extent.Text;
                        Line       = $element.Extent.StartLineNumber;
                        Position   = $element.Extent.StartColumnNumber
                        ParentText = $element.Parent.Extent.Text
                        rawElement = $element
                    }
                    $all_elements += $match
                }
            }
            else
            {
                $all_elements = $matchedElements
            }
        }
    }
    End
    {
        if ($all_elements)
        {
            return $all_elements
        }
        else
        {
            return $null
        }
    }
}