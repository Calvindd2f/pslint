---
name: Bug report 🐛
about: Report errors or unexpected behavior 🤔
---

# Before submitting a bug report

- Make sure you are able to repro it on the latest released version
- Perform a quick search for existing issues to check if this bug has already been reported

## Steps to reproduce

```PwSh

```

## Expected behavior

```none

```

## Actual behavior

```none

```

If an unexpected error was thrown then please report the full error details using e.g. `$error[0] | Select-Object *` .

## Environment data

<!-- Provide the output of the following 2 commands -->

```PwSh
> $PSVersionTable

> (Get-Module -ListAvailable $_).Version | ForEach-Object { $_.ToString() }

> $ExecutionContext.SessionState

# PowerShell Core chads can use:
> Get-Error

> [environment]::StackTrace

> [environment]::IsPrivilegedProcess

> [Environment]::ProcessPath

> [Environment]::CurrentDirectory

> [Environment]::CommandLine

> [Environment]::ExpandEnvironmentVariables("$HOME")

> [string] $errorMessage = $_.Exception.ToString()

> [string] $errorDetails = $_.ErrorDetails
```
