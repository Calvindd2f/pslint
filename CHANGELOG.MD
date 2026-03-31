# Changelog

## v2.1.1

### Added or Changed

- Handled missing inputs at invocation (print module info and prompt for input path)
- Stopped auto-printing text report on invoke
- Supported output formats: textonly, JSON, CSV, stdout (default)
- Supported output path parameter (defaulting to current directory)
- Implemented concise console report output (Script, Time, Summary, Total Issues, Issue breakdown)
- Integrated PowerShellScriptAnalyzer via -QueuePSSA and -PSSAConfig
- Updated PSCI.yml for C# CQL checks before b&r
- Integrated .markdownlint.yml (is it .markdownlint.yaml?)
- Updated build.ps1
- Minimized PSGallery published package contents

## v2.1.0

### Removed

- Removed legacy script-based `Internal` and `Rules` directories.
- Removed outdated `docs` and legacy unit tests.

### Added or Changed

- Migrated to a high-performance C# compiled binary module (`PslintLib.dll`).
- Updated README and GitHub Actions workflow for the binary module.

## v1.0

### Added or Changed

- Fixed back to top alignment (revert changes)
- Implemented pretty console output for CI
- Added output from the endblock that isn't completely awful looking

### Removed

- `pslint.ps1` : pslint function was redefined under the pslint.psm1 file so that the function is imported at the same time as the module itself.
