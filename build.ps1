param(
    [switch]$SkipTests
)

$ErrorActionPreference = "Stop"

$distDir = Join-Path $PSScriptRoot "dist"
$pslintDistDir = Join-Path $distDir "pslint"
if (Test-Path $distDir) {
    Remove-Item -Path $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $pslintDistDir -Force | Out-Null

Write-Host "Building C# Project..."
dotnet build "$PSScriptRoot\src\PslintLib\PslintLib.csproj" -c Release

if ($LASTEXITCODE -ne 0) {
    throw "Build failed!"
}

Write-Host "Copying artifacts for packaging..."
# Copy the compiled DLL
Copy-Item "$PSScriptRoot\src\PslintLib\bin\Release\netstandard2.0\PslintLib.dll" -Destination $pslintDistDir -Force
# Copy the manifest
Copy-Item "$PSScriptRoot\pslint.psd1" -Destination $pslintDistDir -Force
# Copy module metadata
Copy-Item "$PSScriptRoot\README.md" -Destination $pslintDistDir -Force
Copy-Item "$PSScriptRoot\LICENSE" -Destination $pslintDistDir -Force

if (-not $SkipTests) {
    Write-Host "Running tests..."
    if (Get-Module Pester -ListAvailable) {
        Import-Module Pester -ErrorAction SilentlyContinue
        # Remove previously loaded module if it exists
        Remove-Module pslint -ErrorAction SilentlyContinue 
        
        # Test the newly compiled module
        $env:PSLINT_TEST_MODULE_PATH = "$pslintDistDir\pslint.psd1"
        Invoke-Pester -Path "$PSScriptRoot\Tests"
    } else {
        Write-Host "Pester not found, skipping tests..."
    }
}

Write-Host "Build complete! Artifacts are in $pslintDistDir."