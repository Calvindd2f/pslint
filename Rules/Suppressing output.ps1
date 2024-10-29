<# Suppressing output

There are many ways to avoid writing objects to the pipeline.

Assignment or file redirection to $null
Casting to [void]
Pipe to Out-Null
The speeds of assigning to $null, casting to [void], and file redirection to $null are almost identical. However, calling Out-Null in a large loop can be significantly slower, especially in PowerShell 5.1.
The times and relative speeds can vary depending on the hardware, the version of PowerShell, and the current workload on the system.


#>

$tests = @{
    'Assign to $null' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            $null = $arraylist.Add($i)
        }
    }
    'Cast to [void]' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            [void] $arraylist.Add($i)
        }
    }
    'Redirect to $null' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            $arraylist.Add($i) > $null
        }
    }
    'Pipe to Out-Null' = {
        $arrayList = [System.Collections.ArrayList]::new()
        foreach ($i in 0..$args[0]) {
            $arraylist.Add($i) | Out-Null
        }
    }
}

10kb, 50kb, 100kb | ForEach-Object {
    $groupResult = foreach ($test in $tests.GetEnumerator()) {
        $ms = (Measure-Command { & $test.Value $_ }).TotalMilliseconds

[pscustomobject]@{
            Iterations        = $_
            Test              = $test.Key
            TotalMilliseconds = [math]::Round($ms, 2)
        }

[GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }

$groupResult = $groupResult | Sort-Object TotalMilliseconds
    $groupResult | Select-Object *, @{
        Name       = 'RelativeSpeed'
        Expression = {
            $relativeSpeed = $_.TotalMilliseconds / $groupResult[0].TotalMilliseconds
            [math]::Round($relativeSpeed, 2).ToString() + 'x'
        }
    }
}