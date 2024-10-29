<#
Strings are immutable. Each addition to the string actually creates a new string big enough to hold the contents of both the left and right operands, then copies the elements of both operands into the new string. For small strings, this overhead may not matter. For large strings, this can affect performance and memory consumption.

There are at least two alternatives:

The -join operator concatenates strings
The .NET [StringBuilder] class provides a mutable string
The following example compares the performance of these three methods of building a string.
#>

$tests = @{
    'StringBuilder'          = {
        $sb = [System.Text.StringBuilder]::new()
        foreach ($i in 0..$args[0])
        {
            $sb = $sb.AppendLine("Iteration $i")
        }
        $sb.ToString()
    }
    'Join operator'          = {
        $string = @(
            foreach ($i in 0..$args[0])
            {
                "Iteration $i"
            }
        ) -join "`n"
        $string
    }
    'Addition Assignment +=' = {
        $string = ''
        foreach ($i in 0..$args[0])
        {
            $string += "Iteration $i`n"
        }
        $string
    }
}

10kb, 50kb, 100kb | ForEach-Object {
    $groupResult = foreach ($test in $tests.GetEnumerator())
    {
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

# These tests were run on a Windows 11 machine in PowerShell 7.4.2. The output shows that the -join operator is the fastest, followed by the [StringBuilder] class.

# The times and relative speeds can vary depending on the hardware, the version of PowerShell, and the current workload on the system.