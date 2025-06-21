<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->

<a id="readme-top"></a>

<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]
[![PowerShell Gallery][psgallery-shield]][psgallery-url]

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/calvindd2f/pslint">
    <img src="https://app-support.com/public/img/plint.webp" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">PSlint</h3>

  <p align="center">
    A performance-focused linter for PowerShell scripts and modules.
    <br />
    <a href="https://github.com/calvindd2f/pslint/wiki"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/calvindd2f/pslint/issues/new?assignees=&labels=bug&template=bug-report---.md&title=">Report Bug</a>
    ·
    <a href="https://github.com/calvindd2f/pslint/issues/new?assignees=&labels=enhancement&template=feature-request---.md&title=">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#features">Features</a></li>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#custom-rules">Custom Rules</a></li>
    <li><a href="#rule-reference">Rule Reference</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

![Product Name Screen Shot](https://app-support.com/public/img/plint.webp)

`pslint` is a static analysis tool for PowerShell that focuses on identifying performance bottlenecks in scripts and modules. Unlike linters that enforce idiomatic style, `pslint` prioritizes optimizations that can significantly reduce resource consumption and execution time. This makes it particularly useful for scenarios like:

- Optimizing long-running scripts.
- Reducing execution time for Azure Functions and Runbooks.
- Improving the performance of resource-intensive modules.



### Features

`pslint` analyzes your code using the Abstract Syntax Tree (AST) to detect a variety of performance issues, including:

- **Output Suppression**: Detects inefficient ways of suppressing output like `| Out-Null` or `> $null` and suggests faster alternatives like `[void]`.
- **Array Addition**: Identifies the use of the `+=` operator on arrays, which can be slow, and recommends using `System.Collections.ArrayList` or `System.Collections.Generic.List[T]`.
- **String Concatenation**: Flags inefficient string concatenation and suggests using methods like the `-f` format operator or `StringBuilder`.
- **Large File Processing**: Warns against reading large files into memory at once with `Get-Content` and suggests using streaming methods.
- **`Write-Host` Usage**: Recommends using `Write-Output` or other appropriate cmdlets over `Write-Host` for better stream control.
- **And more...**: Including checks for large collection lookups, inefficient loops, and dynamic object creation with `Add-Member`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Custom Rules
<!-- GETTING STARTED -->

## Getting Started

### Prerequisites

No prerequisites required for using this module. It is compatible with both Windows PowerShell and PowerShell Core.

### Installation

Install `pslint` from the PowerShell Gallery:

```pwsh
Install-Module -Name pslint -Repository PSGallery -Scope CurrentUser
Import-Module pslint
```


<!-- USAGE EXAMPLES -->

## Usage

You can analyze a script file directly or analyze a `ScriptBlock` object.

**Analyze a file:**

```powershell
pslint -Path 'C:\path\to\your-script.ps1'
```

**Analyze a ScriptBlock:**

```powershell
$scriptBlock = {
    $myArray = @()
    1..1000 | ForEach-Object { $myArray += $_ }
    $myArray | Out-Null
}
pslint -ScriptBlock $scriptBlock
```

**Example Output:**

```pwsh
 === PowerShell Performance Analysis Report ===
 Script: C:\Users\c\win10_portscan.ps1
 Time: 2024-10-08 03:32:45

 Summary:
 Total Issues Found: 19

 == ArrayAddition (2 issues) ==

   Line 81:
     Code:
       $IPList.Add($CurrIP)
     Suggestion: Consider using ArrayList or Generic List for better performance

   Line 135:
     Code:
       $hosts += [PSCustomObject]@{
         value = "$($($IP.IP).Trim())";
         port = "$($Port.Trim())";
         }
     Suggestion: Consider using ArrayList or Generic List for better performance

 == LargeCollectionLookup (1 issues) ==
   Line 135:
     Code:
     @{
         value = "$($($IP.IP).Trim())";
         port = "$($Port.Trim())";
     }
     Suggestion: Consider using Dictionary<TKey,TValue> for large collections

 == OutputSuppression (10 issues) ==
   Line 8:
     Code: $null|out-null
     Suggestion: Consider using [void] for better performance

   Line 9:
     Code: $null|out-null
     Suggestion: Consider using [void] for better performance

 == WriteHostUsage (6 issues) ==
   Line 97:
     Code:
       Write-Host "WARNING: Scan took longer than 15 seconds, ARP entries may have been flushed. Recommend lowering DelayMS parameter"
     Suggestion: Consider using [Console]::writeline() , Write-Output or Write-Information.
   Line 119:
     Code:
       Write-host "Started scanning at $($start_time)"
     Suggestion: Consider using [Console]::writeline() , Write-Output or Write-Information.
   Line 172:
     Code:
       Write-Host "Hosts Found: $($hosts.Count)"
     Suggestion: Consider using [Console]::writeline() , Write-Output or Write-Information.
   Line 175:
     Code:
       write-host $(ConvertTo-Json $hosts -Depth 5)
     Suggestion: Consider using [Console]::writeline() , Write-Output or Write-Information.
   Line 183:
     Code:
       Write-Host "Total Time: $($total.ToString())"
     Suggestion: Consider using [Console]::writeline() , Write-Output or Write-Information.
   Line 184:
     Code:
       Write-Host "Finished scanning at $($end_time)"
     Suggestion: Consider using [Console]::writeline() , Write-Output or Write-Information.
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Custom Rules

`pslint` can also evaluate rules provided in your own modules. Export your rule functions and specify their paths in a ScriptAnalyzer settings file:

```powershell
$settings = @{
    CustomRulePath = '.\\MyRules'
    IncludeRules   = 'Measure-*'
}
Invoke-ScriptAnalyzer -Path .\script.ps1 -Settings $settings
```

In Visual Studio Code set "powershell.scriptAnalysis.settingsPath" to the settings file so custom rules run automatically.

## Rule Reference

For details on the built-in rules and examples of recommended fixes see [docs/rules_overview.md](docs/rules_overview.md).

<!-- ROADMAP -->

## Roadmap

- [x] Reliable detection via Abstract Syntax Tree (AST) parsing.
- [x] Formatted and actionable output.
- [x] Published to PowerShell Gallery.
- [x] Improve accuracy through extensive real-world testing.
- [x] Implement corrective actions (auto-fixing).
- [x] Enhance rule documentation and provide clear examples.

See the [open issues](https://github.com/calvindd2f/pslint/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Top contributors

<a href="https://github.com/calvindd2f/pslint/graphs/contributors">
<img src="https://contrib.rocks/image?repo=calvindd2f/pslint" alt="contrib.rocks image" />
</a>

<!-- LICENSE -->

## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->

## Contact

Project Maintainer: [@Calvindd2f](https://twitter.com/Dreadytofat) - <calvin@app-support.com>

Project Link: [https://github.com/calvindd2f/pslint](https://github.com/calvindd2f/pslint)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- [Best README Template](https://github.com/othneildrew/Best-README-Template)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

- [PowerShell](https://learn.microsoft.com/en-us/powershell/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[contributors-shield]: https://img.shields.io/github/contributors/calvindd2f/pslint.svg?style=for-the-badge
[contributors-url]: https://github.com/calvindd2f/pslint/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/calvindd2f/pslint.svg?style=for-the-badge
[forks-url]: https://github.com/calvindd2f/pslint/network/members
[stars-shield]: https://img.shields.io/github/stars/calvindd2f/pslint.svg?style=for-the-badge
[stars-url]: https://github.com/calvindd2f/pslint/stargazers
[issues-shield]: https://img.shields.io/github/issues/calvindd2f/pslint.svg?style=for-the-badge
[issues-url]: https://github.com/calvindd2f/pslint/issues
[license-shield]: https://img.shields.io/github/license/calvindd2f/pslint.svg?style=for-the-badge
[license-url]: https://github.com/calvindd2f/pslint/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[psgallery-shield]: https://img.shields.io/powershellgallery/v/pslint.svg?style=for-the-badge&logo=powershell&label=PowerShell%20Gallery
[psgallery-url]: https://www.powershellgallery.com/packages/pslint

```

```
