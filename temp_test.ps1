$ErrorActionPreference = 'Continue'
Import-Module ./dist/pslint/pslint.psd1 -Force
Write-Host "Loaded modules:"
Get-Module pslint
Write-Host "Testing pslint..."
pslint -ScriptBlock { Write-Host 'Hello World' }
Write-Host "Done."
