# PSLint

**Performance-focused static analysis for PowerShell.**

`pslint` is a statically compiled C# PowerShell module that analyzes PowerShell source code through the PowerShell Abstract Syntax Tree (AST), identifying patterns that can introduce unnecessary execution time, allocations, or resource consumption.

Unlike conventional PowerShell linting, `pslint` is deliberately interested in a different question:

> **"Is this valid and idiomatic PowerShell, and what does it actually cost?"**

It complements [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) rather than attempting to replace it.

---

## Why PSLint?

PowerShell's abstractions make many operations convenient, but convenience can hide significant runtime costs.

For example, repeatedly using `+=` with an array causes the array to be reallocated and copied as it grows:

```powershell
$items = @()

foreach ($item in $source) {
    $items += $item
}
```

`pslint` can identify this pattern and recommend an alternative:

```powershell
$items = [System.Collections.Generic.List[object]]::new()

foreach ($item in $source) {
    $items.Add($item)
}
```

The important distinction is that `pslint` does not simply label the first example as "bad PowerShell". It identifies **why the construct can become expensive and when the optimization is worth considering**.

---

## Example

```text
PSL001  Array addition inside a loop

Severity: Performance

Detected:
    $items += $item

Recommendation:
    Consider System.Collections.Generic.List[T] for
    repeated collection growth.

Reason:
    PowerShell arrays cannot grow in place. Repeated +=
    operations can result in repeated allocation and copying.

Category:
    Allocation / Collection Growth
```

Where possible, rules are backed by reproducible benchmarks rather than purely stylistic preferences.

---

## Performance trade-offs

`pslint` is based on a simple premise:

> **Idiomatic PowerShell and performant PowerShell are not always the same thing.**

This isn't a criticism of PowerShell's abstractions. They're a major part of what makes PowerShell productive and readable.

The problem is that some abstractions have costs that become significant at scale.

Microsoft documents several of these trade-offs in its own [PowerShell scripting performance considerations](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/script-authoring-considerations?view=powershell-7.6), including pipeline overhead, array growth, string concatenation, collection enumeration, and output suppression.

### A real-world example: array addition

Microsoft's benchmark compares explicit PowerShell assignment, `List<T>.Add()`, and repeated `+=` array addition.

On their Windows 11 / PowerShell 7.3.4 test system, at 102,400 elements:

| Approach                       |          Time |   Relative |
| ------------------------------ | ------------: | ---------: |
| PowerShell explicit assignment |      11.18 ms |         1× |
| `List<T>.Add()`                |   1,384.03 ms |     123.8× |
| Array `+=`                     | 201,991.06 ms | 18,067.18× |

The important point isn't the absolute timing. Hardware, PowerShell version, workload, and runtime implementation all affect the result.

The important point is the **shape of the performance difference**.

Microsoft notes that array addition was optimized in PowerShell 7.5, so this particular behavior is especially relevant when analyzing older PowerShell versions.

This is exactly the kind of pattern `pslint` is designed to surface.

```powershell
$results = @()

foreach ($item in $source) {
    $results += $item
}
```

Rather than simply reporting:

```text
"Don't use += because it's slow."
```

`pslint` can identify the underlying construct and suggest an appropriate alternative:

```powershell
$results = [System.Collections.Generic.List[object]]::new()

foreach ($item in $source) {
    $results.Add($item)
}
```

The optimization should still be evaluated against the actual workload.

For a small collection, the difference may be irrelevant. For a large collection inside a long-running automation job, it can become a significant bottleneck.

---

### Pipeline overhead

The same principle applies to pipeline structure.

Microsoft demonstrates a case where moving `Export-Csv` outside a `ForEach-Object` pipeline reduced execution time from approximately **15.97 seconds to 42.92 milliseconds**, a roughly **372× difference** in that particular benchmark.

```text
Export-Csv invoked inside the loop
    15,968.78 ms

Export-Csv invoked once
        42.92 ms

             ~372×
```

This isn't a universal performance multiplier. It's an example of how an otherwise reasonable PowerShell abstraction can become extremely expensive when placed at the wrong level of a loop or pipeline.

This is the class of problem `pslint` is intended to detect.

---

### Output suppression

Microsoft also benchmarks several common approaches to suppressing pipeline output.

At 10,240 iterations on their test system:

| Method                |     Time | Relative |
| --------------------- | -------: | -------: |
| Assignment to `$null` | 36.74 ms |       1× |
| Redirect to `$null`   | 55.84 ms |    1.52× |
| `[void]` cast         | 62.96 ms |    1.71× |
| `Out-Null`            | 81.65 ms |    2.22× |

The difference changes with workload and PowerShell version, but the benchmark demonstrates why a performance-focused analyzer may reasonably flag `Out-Null` inside a hot loop.

---

### Measure before optimizing

These examples also illustrate an important design principle behind `pslint:

**a performance rule is not automatically a recommendation to rewrite the code.**

The useful question is:

```text
Is this pattern present?
        │
        ▼
Could it become expensive?
        │
        ▼
Does the workload make the cost relevant?
        │
        ▼
Measure
        │
        ▼
Optimize if justified
```

`pslint` therefore aims to provide context around performance-sensitive constructs rather than treating idiomatic PowerShell as inherently inefficient.

The goal is not to replace readable PowerShell with low-level .NET code everywhere.

> **The goal is to make the cost of an abstraction visible when that cost matters.**


---

## What it analyzes

`pslint` currently includes rules covering areas such as:

| Category    | Examples                                                       |
| ----------- | -------------------------------------------------------------- |
| Collections | Repeated array `+=`, expensive collection operations           |
| Output      | `Out-Null`, `$null` redirection and other suppression patterns |
| Strings     | Repeated concatenation and formatting                          |
| File I/O    | Large-file processing and unnecessary buffering                |
| Loops       | Expensive operations inside iterative constructs               |
| Objects     | Repeated dynamic object creation                               |
| Lookups     | Inefficient large-collection searches                          |
| General     | Other patterns with measurable performance implications        |

The analyzer operates on the PowerShell AST, allowing rules to reason about the structure of the source rather than relying exclusively on text matching or regular expressions.

---

## Architecture

`pslint` is implemented as a native C# binary PowerShell module.

```text
PowerShell source
       │
       ▼
PowerShell Parser
       │
       ▼
Abstract Syntax Tree
       │
       ▼
C# Analysis Engine
       │
       ├── Performance Rules
       ├── Pattern Analysis
       └── PSScriptAnalyzer Integration
       │
       ▼
Diagnostics
       │
       ├── Console
       ├── JSON
       ├── CSV
       └── Plaintext
```

The C# implementation was chosen to keep the analysis engine compiled while still integrating directly with PowerShell's parsing and scripting infrastructure.

---

## Performance analysis

Performance rules are intended to identify situations where PowerShell's abstractions can become expensive at scale.

For example, collection growth, repeated allocations, file buffering, and high-frequency pipeline operations can behave very differently depending on the size and shape of the workload.

Where appropriate, `pslint` provides benchmark support to validate these differences.

```powershell
pslint -Path .\script.ps1 -BenchmarkMode
```

The goal is not to blindly replace idiomatic PowerShell with lower-level code.

The goal is to make the trade-off visible.

> **Readable and idiomatic code is usually the right default. Performance-oriented alternatives become interesting when measurement shows that the abstraction is part of the bottleneck.**

---

## PSScriptAnalyzer integration

`pslint` is designed to complement Microsoft's [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer).

PSScriptAnalyzer provides broad PowerShell quality, style, and correctness analysis.

`pslint` focuses primarily on **performance-oriented analysis**.

Both can be executed as part of the same analysis workflow:

```powershell
pslint `
    -Path .\script.ps1 `
    -QueuePSSA
```

---

## Installation

Install from the PowerShell Gallery:

```powershell
Install-Module -Name pslint -Repository PSGallery -Scope CurrentUser

Import-Module pslint
```

`pslint` supports Windows PowerShell and PowerShell Core.

---

## Usage

Analyze a script:

```powershell
pslint -Path .\script.ps1
```

Analyze a `ScriptBlock`:

```powershell
$scriptBlock = {
    $items = @()

    foreach ($item in 1..1000) {
        $items += $item
    }

    $items | Out-Null
}

pslint -ScriptBlock $scriptBlock
```

Run performance benchmarks and PSScriptAnalyzer:

```powershell
pslint `
    -Path .\script.ps1 `
    -BenchmarkMode `
    -QueuePSSA
```

Export results:

```powershell
pslint `
    -Path .\script.ps1 `
    -OutputFormat JSON `
    -OutputPath .\results.json
```

---

## Rule design

Rules are intended to provide four things:

1. **Detection**
   Identify the relevant AST pattern.

2. **Context**
   Explain what was detected and why it matters.

3. **Recommendation**
   Provide a practical alternative where one exists.

4. **Evidence**
   Where meaningful, provide benchmarks or references demonstrating the underlying performance characteristic.

This is particularly important for performance rules because an optimization that is valuable for a 100,000-item workload may be irrelevant for a 10-item script.

---

## Design philosophy

`pslint` deliberately does not treat "idiomatic PowerShell" and "fast PowerShell" as synonyms.

PowerShell's abstractions are valuable. They improve readability, composability, and developer productivity.

However, abstractions can also introduce costs.

`pslint` exists to identify cases where those costs may become relevant.

The intended workflow is therefore:

```text
Idiomatic PowerShell
        │
        ▼
      Analyze
        │
        ▼
   Identify hotspot
        │
        ▼
      Measure
        │
        ▼
 Optimize if justified
```

The recommendation is not always "write less idiomatic code."

It is:

> **Know when the abstraction is costing you something.**

---

## Custom rules

`pslint` can be extended with custom rules through the existing PSScriptAnalyzer rule infrastructure.

Example:

```powershell
$settings = @{
    CustomRulePath = '.\MyRules'
    IncludeRules   = 'Measure-*'
}

Invoke-ScriptAnalyzer `
    -Path .\script.ps1 `
    -Settings $settings
```

---

## Roadmap

* [x] AST-based analysis
* [x] Performance-oriented rules
* [x] PSScriptAnalyzer integration
* [x] PowerShell Gallery distribution
* [x] Multiple output formats
* [x] Benchmark mode
* [x] Actionable diagnostics
* [x] Auto-fix support
* [ ] Expanded benchmark coverage
* [ ] Additional performance rules
* [ ] Improved rule documentation

See [open issues](https://github.com/calvindd2f/pslint/issues) for current work.

---

## License

MIT

---

## Author

**Calvin Bergin**

[GitHub](https://github.com/calvindd2f)
