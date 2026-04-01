# Changelog

All notable changes to the `pslint` project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v2.2.0]

### Added
- **Native JSON Serialization**: Massively improved JSON output performance by replacing the PowerShell pipeline with native .NET `System.Text.Json` serialization.
- **Cross-Platform Testing**: The CI/CD workflow matrix now properly builds and tests the module on Windows, Ubuntu, and macOS using both `pwsh` and legacy `powershell`.
- **Improved Cmdlet Safety**: Avoided sync-over-async thread deadlocks with a unified wait approach during benchmark execution.
- **Strict Dependencies**: Removed in-flight `PSScriptAnalyzer` dynamic installation. Module manifest now natively requires `PSScriptAnalyzer`.
- **Dependency Isolation**: Cleaned up the `PslintLib.csproj` SDK references, dropping `Microsoft.PowerShell.SDK` in favor of strict `PowerShellStandard.Library`.

---

## [v2.1.2]

### Added
- **Benchmark Mode**: Added `-BenchmarkMode` to execute performance benchmarks asynchronously before AST inspection.
- **Default Benchmarks**: Implemented built-in comparison tests for `Array Addition (+=)` vs `List<T>.Add()` and `ForEach-Object` Pipeline vs `foreach` Statements.
- **Custom Benchmarks**: Support for isolated `before` and `after` script execution within managed runspaces via `-BenchmarkModeFileBefore` and `-BenchmarkModeFileAfter`.
- **.ps1xml Support**: Added parsing support for `.ps1xml` files to evaluate performance anomalies in formatting and type configurations.
- **Samples**: Provided sample scripts within the repository to easily test the `pslint` rules externally.

### Removed
- **markdownlint.yml**: Removed the local `.markdownlint.yml` configuration.

---

## [v2.1.1]

### Added
- **Dynamic Input Prompting**: Successfully handles missing `Path` parameters by outputting the module version and interactively prompting the user.
- **Output Formats**: Enhanced the `-OutputFormat` parameter to support:
  - `stdout` (default styled console output)
  - `textonly` (clean plaintext summary format)
  - `JSON`
  - `CSV`
- **Output File Persistence**: Added the `-OutputPath` parameter which defaults to the current execution directory.
- **PSScriptAnalyzer Integration**: Added native support for invoking Microsoft's `PSScriptAnalyzer`.
  - Use `-QueuePSSA` to install and run analyzing cleanly inside the Runspace.
  - Optionally specify rulesets via `-PSSAConfig`.
- **Refined Console Report**: Formatted the default STDOUT report logically, categorizing errors and their respective lines and suggestions.
- **CI Enhancements**: Updated GitHub Actions (`PSCI.yml`) to enforce C# `CodeQL` analysis checks prior to build and release stages.
- **Build Scripts**: Updated `build.ps1` to reflect the new compiled deployment strategy.

### Changed
- **PSGallery Footprint**: Minimized published package contents for a leaner distribution.
- **Reporting Defaults**: Halted automatic aggressive console spam when invoking tests programmatically.

---

## [v2.1.0]

### Added
- **Core Engine Transformation**: Completely migrated `pslint` from an interpreted PowerShell script tool to a high-performance C# compiled binary module (`PslintLib.dll`).
- **Binary Architecture Docs**: Updated documentation and GitHub Actions workflows to execute the `.NET` builds natively.

### Removed
- **Legacy Structure**: Removed outdated script dependencies, unit tests, and the `Internal` & `Rules` parsing directories.

---

## [v1.0.0]

### Added
- **Console Output Improvements**: Introduced pretty reporting schemas for clean CI logging.
- **Endblock Enhancements**: Improved final pipeline outputs.

### Fixed
- **Markdown Docs**: Restored specific align components for "back to top" link formatting.

### Removed
- **Function Sprawl**: Relocated the `pslint.ps1` function definition directly into `pslint.psm1` so that module and command aliases populate cleanly upon import.
