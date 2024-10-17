function Monitor-ProcessMemory
{
    param (
        [Parameter(Mandatory = $true)]
        [string]$ProcessName,
        [int]$IntervalMs = 120,
        [int]$DurationSeconds = 60
    )

    $endTime = [datetime]::Now.AddSeconds($DurationSeconds)

    while ([datetime]::Now -lt $endTime)
    {
        $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($processes)
        {
            foreach ($process in $processes)
            {
                $memoryMB = [math]::Floor($process.PrivateMemorySize64 / 1MB)
                $timestamp = [datetime]::Now.ToString('yyyy-MM-dd HH:mm:ss.fff')
                Write-Output "$timestamp - $($process.Name) (ID: $($process.Id)) Memory Usage: $memoryMB MB"
            }
        }
        else
        {
            Write-Warning "Process $ProcessName not found."
            break
        }
        Start-Sleep -Milliseconds $IntervalMs
    }
}

# Example usage:
# Monitor-ProcessMemory -ProcessName "pwsh" -IntervalMs 120 -DurationSeconds 10