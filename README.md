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

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/calvindd2f/pslint">
    <img src="https://app-support.com/public/img/plint.webp" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">PSlint</h3>

  <p align="center">
    Performance focused linter for PowerShell scripts and modules
    <br />
    <a href="https://github.com/calvindd2f/pslint"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/calvindd2f/pslint">View Demo</a>
    ·
    <a href="https://github.com/calvindd2f/pslint/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/calvindd2f/pslint/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
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

This is a module for linting performance of PowerShell modules and scripts. This is performance focused so idiomatic PowerShell is not adhered to. Please consider this when weighing maintainability versus performance needs. This module has use cases when a module is encountering resource exhaustion or if you are trying to reduce the time take for Azure Runbooks. The use-cases are non-exhaustive.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->

## Getting Started

### Prerequisites

No prerequisites required for using this module

### Installation

1. Install/Import the module

   ```pwsh
   Install-Module pslint ; Import-Module pslint
   ```

2. Call pslint to the target file or scriptblock

   ```pwsh
   pslint -Path 'C:\win10_portscan.ps1'
   ```

3. Output

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

<!-- USAGE EXAMPLES -->

## Usage

_For more examples, please refer to the [Documentation](https://app-support.com)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->

## Roadmap

- [x] Reliable detection
- [x] Beautified Output Formatting
- [ ] Accurate detection (via extensive testing.)
- [ ] Pushing module to PSGallery
- [ ] Conversion to a CI/CD workflow and a dockerfile for the aforemention workflow.
- [ ] Corective action implementation
- [ ] Testing

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

Your Name - [@Dreadytofat](https://twitter.com/Dreadytofat) - <calvin@app-support.com>

Project Link: [https://github.com/calvindd2f/pslint](https://github.com/calvindd2f/pslint)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->

## Acknowledgments

- []()

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

![PowerShell 7](https://www.learningkoala.com/media/posts/21/PowerShell_Black_Logo_600x600.png)

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
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com

```

```
