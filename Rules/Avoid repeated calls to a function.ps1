# Calling a function can be an expensive operation. If you're calling a function in a long running tight loop, consider moving the loop inside the function.

$tests = @{
    'Simple for-loop'       = {
        param([int] $RepeatCount, [random] $RanGen)

for ($i = 0; $i -lt $RepeatCount; $i++) {
            $null = $RanGen.Next()
        }
    }
    'Wrapped in a function' = {
        param([int] $RepeatCount, [random] $RanGen)

function Get-RandomNumberCore {
            param ($rng)

$rng.Next()
        }

for ($i = 0; $i -lt $RepeatCount; $i++) {
            $null = Get-RandomNumberCore -rng $RanGen
        }
    }
    'for-loop in a function' = {
        param([int] $RepeatCount, [random] $RanGen)

function Get-RandomNumberAll {
            param ($rng, $count)

for ($i = 0; $i -lt $count; $i++) {
                $null = $rng.Next()
            }
        }

Get-RandomNumberAll -rng $RanGen -count $RepeatCount
    }
}

5kb, 10kb, 100kb | ForEach-Object {
    $rng = [random]::new()
    $groupResult = foreach ($test in $tests.GetEnumerator()) {
        $ms = Measure-Command { & $test.Value -RepeatCount $_ -RanGen $rng }

[pscustomobject]@{
            CollectionSize    = $_
            Test              = $test.Key
            TotalMilliseconds = [math]::Round($ms.TotalMilliseconds,2)
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

# The Basic for-loop example is the base line for performance. The second example wraps the random number generator in a function that's called in a tight loop. The third example moves the loop inside the function. The function is only called once but the code still generates the same amount of random numbers. Notice the difference in execution times for each example.