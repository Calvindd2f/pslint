# The idiomatic way to process a file in PowerShell might look something like:
Get-Content $path | Where-Object Length -GT 10

# This can be an order of magnitude slower than using .NET APIs directly. For example, you can use the .NET [StreamReader] class:
try {
    $reader = [System.IO.StreamReader]::new($path)
    while (-not $reader.EndOfStream) {
        $line = $reader.ReadLine()
        if ($line.Length -gt 10) {
            $line
        }
    }
}
finally {
    if ($reader) {
        $reader.Dispose()
    }
}

# You could also use the ReadLines method of [System.IO.File], which wraps StreamReader, simplifies the reading process:

foreach ($line in [System.IO.File]::ReadLines($path))
{
    if ($line.Length -gt 10)
    {
        $line
    }
}