# PSLint Rule Reference

This document summarizes the built-in performance rules that `pslint` checks. Each section describes the issue being detected and provides a brief code example.

## Output Suppression
Avoid using `Out-Null` or assigning to `$null` to suppress output.

```powershell
# Bad
Get-Process | Out-Null

# Good
[void](Get-Process)
```

## Array Addition
Appending to arrays with `+=` creates a new array each time.

```powershell
# Bad
$items = @()
1..10 | ForEach-Object { $items += $_ }

# Good
$items = [System.Collections.Generic.List[int]]::new()
1..10 | ForEach-Object { $items.Add($_) }
```

## String Addition
Repeated string concatenation can be slow.

```powershell
# Bad
$msg = ""
1..5 | ForEach-Object { $msg += $_ }

# Good
$msg = [System.Text.StringBuilder]::new()
1..5 | ForEach-Object { [void]$msg.Append($_) }
$msg.ToString()
```

## Large File Processing
Avoid loading large files entirely into memory.

```powershell
# Bad
$content = Get-Content -Path big.log

# Good
Get-Content -Path big.log -ReadCount 100 | ForEach-Object {
    # process lines
}
```

## Large Collection Lookup
Hashtables may be slow for huge collections.

```powershell
# Consider using a generic dictionary for very large lookups
$dict = [System.Collections.Generic.Dictionary[string,int]]::new()
```

## Write-Host Usage
Prefer `Write-Output` or logging cmdlets for script output.

```powershell
# Bad
Write-Host "Finished"

# Good
Write-Output "Finished"
```

## Large Loops
Extremely large loops can hurt performance. Optimize or use .NET methods when possible.

## Repeated Function Calls
Avoid calling the same function in tight loops with identical parameters. Cache results if possible.

## Cmdlet Pipeline Wrapping
Filtering with `Where-Object` after a cmdlet can be slower than using a native `-Filter` parameter.

```powershell
# Bad
Get-Service | Where-Object Name -eq 'Spooler'

# Good
Get-Service -Name 'Spooler'
```

## Dynamic Object Creation
Creating `[PSCustomObject]` objects inside loops may slow down execution. Consider defining a class for large datasets.

## EnhancedSecretManagementRule
Checks for insecure secret handling practices such as plain text passwords or insecure `Read-Host` usage.

