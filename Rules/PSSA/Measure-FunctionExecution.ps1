function Measure-FunctionExecution
{
    param (
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        [string]$FunctionName = 'Unnamed Function'
    )

    $startTime = Get-Date
    $error.Clear()

    try
    {
        $result = & $ScriptBlock
        $endTime = Get-Date
        $duration = $endTime - $startTime

        [PSCustomObject]@{
            FunctionName = $FunctionName
            StartTime    = $startTime.ToString('yyyy-MM-dd HH:mm:ss.fff')
            EndTime      = $endTime.ToString('yyyy-MM-dd HH:mm:ss.fff')
            Duration     = $duration
            Result       = $result
            Error        = $null
        }
    }
    catch
    {
        $endTime = Get-Date
        $duration = $endTime - $startTime

        [PSCustomObject]@{
            FunctionName = $FunctionName
            StartTime    = $startTime.ToString('yyyy-MM-dd HH:mm:ss.fff')
            EndTime      = $endTime.ToString('yyyy-MM-dd HH:mm:ss.fff')
            Duration     = $duration
            Result       = $null
            Error        = $_.Exception.Message
        }
    }
}

# Example usage:
# $result = Measure-FunctionExecution -ScriptBlock { Start-Sleep -Seconds 2; Get-Process } -FunctionName "Get-Process with delay"
# $result | Format-List
# Example usage:
# Monitor-ProcessMemory -ProcessName "powershell" -IntervalMs 120 -DurationSeconds 10
# Measure-FunctionExecution -ScriptBlock { Start-Sleep -Seconds 2; Get-Process } -FunctionName "Get-Process with delay"
<#
$result = Measure-FunctionExecution -ScriptBlock {
    Start-Sleep -Seconds 2
    Get-Process
} -FunctionName "Get-Process with delay"

$result | Format-List

# If you want to display the duration in a specific format, you can do:
"Duration: {0:hh\:mm\:ss\.fff}" -f $result.Duration
#>