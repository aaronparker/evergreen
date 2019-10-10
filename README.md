# About

[![License][license-badge]][license]

Evergreen is a simple PowerShell module to get latest version and download URLs for various products. The module consists of a number of simple commands to use in scripts when performing several tasks including:

* Retrieve the latest version of a particular software product when comparing against a version already installed or downloaded
* Return the URL for the latest version of a software product if you need to download it locally

All functions consist of the following

* Get verb - the module provides functions to retrieve data only
* Vendor - the vendor / developer of the application (e.g. Adobe, Google, Microsoft)
* Product name - product names and optionally version (e.g. Reader DC, Chrome, VisualStudioCode)

## Why

There are several community and commercial products that manage application deployment and updates already. This module isn't intended to compete against those. Instead the focus is on simple integration for PowerShell scripts to provide product version numbers and download URLs. Data will only be pulled from the vendor web site and never a third party.

## Who

This module is maintained by the following community members

* Aaron Parker, [@stealthpuppy](https://twitter.com/stealthpuppy)
* Bronson Magnan, [@CIT_Bronson](https://twitter.com/CIT_Bronson)
* Trond Eric Haarvarstein, [@xenappblog](https://twitter.com/xenappblog)

## Installing the Module

### Manual Installation from the Repository

The module can be downloaded from the [GitHub source repository](https://github.com/aaronparker/Evergreen) and includes the module in the `Evergreen` folder. The folder needs to be installed into one of your PowerShell Module Paths. To see the full list of available PowerShell Module paths, use `$env:PSModulePath.split(';')` in a PowerShell console.

Common PowerShell module paths include:

* Current User: `%USERPROFILE%\Documents\WindowsPowerShell\Modules\`
* All Users: `%ProgramFiles%\WindowsPowerShell\Modules\`
* OneDrive: `$env:OneDrive\Documents\WindowsPowerShell\Modules\`

To install from the repository

1. Download the `master branch` to your workstation
2. Copy the contents of the Evergreen folder onto your workstation into the desired PowerShell Module path
3. Open a Powershell console with the Run as Administrator option
4. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`
5. Unblock the files with `Get-ChildItem -Path <path to module> -Recurse | Unblock-File`

Once installation is complete, you can validate that the module exists by running `Get-Module -ListAvailable Evergreen`. To use the module, load it with:

```powershell
Import-Module Evergreen
```

### PowerShell Gallery

As soon as we get the module into a consistent state, we'll post it to the PowerShell Gallery, making it easy to install with:

```powershell
Install-Module Evergreen
```

[appveyor-badge]: https://img.shields.io/appveyor/ci/aaronparker/Evergreen/master.svg?style=flat-square&logo=appveyor
[appveyor-build]: https://ci.appveyor.com/project/aaronparker/Evergreen
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/Evergreen.svg?style=flat-square
[psgallery]: https://www.powershellgallery.com/packages/Evergreen
[psgallery-version-badge]: https://img.shields.io/powershellgallery/v/Evergreen.svg?style=flat-square
[psgallery-version]: https://www.powershellgallery.com/packages/Evergreen
[github-release-badge]: https://img.shields.io/github/release/aaronparker/Evergreen.svg?style=flat-square
[github-release]: https://github.com/aaronparker/Evergreen/releases/latest
[license-badge]: https://img.shields.io/github/license/aaronparker/Evergreen.svg?style=flat-square
[license]: https://github.com/aaronparker/Evergreen/blob/master/LICENSE
