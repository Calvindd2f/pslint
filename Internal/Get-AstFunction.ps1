Function Get-AstFunction
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
            File Name	: Get-AstFunction
            Version     : 1.0

        .LINK
    #>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Array of files")]
        [Object]$objects,

        [Parameter(Mandatory = $false, HelpMessage = "Recursive Search")]
        [Switch]$recursive
    )
    Begin
    {
        $all_functions = @()
        $tokens = $errors = $null
    }
    Process
    {
        foreach ($object in $objects)
        {
            if ($object -isnot [System.IO.FileSystemInfo])
            {
                if ($object -is [System.Management.Automation.PSObject] -and $null -ne $object.Psobject.Properties.Item('FullName'))
                {
                    #Convert to filesystemInfo
                    $object = [System.IO.fileinfo]::new($object)
                }
                elseif ($object -is [System.String])
                {
                    #Convert to filesystemInfo
                    $object = [System.IO.fileinfo]::new($object)
                }
            }
            if ($object -is [System.IO.FileSystemInfo])
            {
                $ast = [System.Management.Automation.Language.Parser]::ParseFile(
                    $object.FullName,
                    [ref]$tokens,
                    [ref]$errors
                )
                if ($recursive)
                {
                    # Get only function definition ASTs
                    $all_functions += $ast.FindAll({
                            param([System.Management.Automation.Language.Ast] $Ast)

                            $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                            # Class methods have a FunctionDefinitionAst under them as well, but we don't want them.
                        ($PSVersionTable.PSVersion.Major -lt 5 -or
                            $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])

                        }, $true)
                }
                else
                {
                    # Get only first function definition ASTs
                    $all_functions += $ast.Find({
                            param([System.Management.Automation.Language.Ast] $Ast)

                            $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                            # Class methods have a FunctionDefinitionAst under them as well, but we don't want them.
                        ($PSVersionTable.PSVersion.Major -lt 5 -or
                            $Ast.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])

                        }, $true)
                }
            }
            elseif ($object -is [string])
            {
                $fnc = Get-Item Function:\$object -ErrorAction SilentlyContinue
                if ($null -ne $fnc)
                {
                    #Check if custom function from local script
                    if ($fnc.ScriptBlock.File)
                    {
                        $local_function = Get-Content Function:\$object
                        $all_functions += $local_function.Ast
                    }
                }
            }
            elseif ($object -is [scriptblock])
            {
                $all_functions += $object.Ast
            }
        }
    }
    End
    {
        if ($all_functions)
        {
            return $all_functions
        }
        else
        {
            return $null
        }
    }
}