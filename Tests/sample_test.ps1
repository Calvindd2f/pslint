Start-Job -ScriptBlock { Write-Host "Hello" }
1..10 | ForEach-Object -Parallel { $_ * 2 }

# Add-Member test
$obj = New-Object PSObject
$obj | Add-Member -NotePropertyName "Prop" -NotePropertyValue 1

# String add
$s = ""
$s += "hello"

# Array add
$a = @()
$a += "something"
