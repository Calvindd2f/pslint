# PSlint Architecture Overview

PSlint has evolved from a traditional PowerShell script module into a high-performance compiled C# binary module. This transition was made to significantly improve Abstract Syntax Tree (AST) parsing speed and enable complex, statically-typed analysis of PowerShell scripts.

## Directory Structure

- **/src/PslintLib/**: The core C# source code directory for the binary module. This replaces the old script-based `Internal` and `Rules` folders.
  - `PslintLib.csproj`: The .NET project file defining dependencies for the module.
  - `InvokePslintCommand.cs`: The main class implementing the `PSCmdlet`. This acts as the entry point when users call `Invoke-Pslint` (or the alias `pslint`).
  - **Analysis/**: A directory containing the C# classes responsible for AST traversal and performance rule evaluation.
    - *Analyzer*: Orchestrates the parsing and rule execution.
    - *ReportGenerator*: Compiles the findings into the standardized output structures (JSON, CSV, plaintext).
  - **Rules/**: The C# compilation of all performance and error detection rules (e.g., ArrayAddition, OutputSuppression, LargeCollectionLookup).

- **/dist/**: Automatically generated build artifacts. Contains the compiled DLL (`PslintLib.dll`) ready for import into PowerShell runspaces.

- **/Tests/**: Holds integration and unit tests for ensuring the stability of the compiled C# logic against various PowerShell edge cases.

## Execution Flow
1. The user invokes the module via `Invoke-Pslint -Path <file>`.
2. The C# Cmdlet initializes the necessary PowerShell runspaces (crucial for isolated execution, such as in `-BenchmarkMode`).
3. The `.ps1` or `ScriptBlock` payload is parsed natively using the `System.Management.Automation.Language.Parser` to generate an AST.
4. Custom C# rule classes visit the AST nodes, performing high-speed inspection for performance bottlenecks.
5. Actionable output is generated and optionally piped to `ConvertTo-Json`, exported as `CSV`, or displayed natively via `Write-Host` / `Write-Object`.
6. (Optional) If `-QueuePSSA` is provided, `PSScriptAnalyzer` is invoked in a clean runspace to provide supplemental linting data.
