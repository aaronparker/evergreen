# About

[![License][license-badge]][license]
[![PowerShell Gallery Version][psgallery-version-badge]][psgallery]
[![PowerShell Gallery][psgallery-badge]][psgallery]
[![Master build status][appveyor-badge]][appveyor-build]

Evergreen is a simple PowerShell module to return the latest version and download URLs for a set of common enterprise applications. The module consists of a number of simple commands to use in scripts when performing several tasks including:

* Retrieve the latest version of a particular software product when comparing against a version already installed or downloaded
* Return the URL for the latest version of a software product if you need to download it locally

All functions consist of the following:

* Get verb - the module provides functions to retrieve data only
* Vendor - the vendor / developer of the application (e.g. Adobe, Google, Microsoft)
* Product name - product names and optionally version (e.g. Reader DC, Chrome, VisualStudioCode)

## Why

There are several community and commercial products that manage application deployment and updates already. This module isn't intended to compete against those. Instead the focus is on simple integration for PowerShell scripts to provide product version numbers and download URLs. Data will only be pulled from the vendor web site and never a third party.

## How

Evergreen uses a couple of approaches to returning the latest version of software. Instead of scraping web pages, the primary methods used are:

1. Application update APIs - by using the same approach as the application itself, Evergreen can consistently return the latest version number and download URI
2. Web APIs - often a vendor download pages will include a query when listing versions and download links. Evergreen can use the same approach

## Who

This module is maintained by the following community members

* Aaron Parker, [@stealthpuppy](https://twitter.com/stealthpuppy)
* Bronson Magnan, [@CIT_Bronson](https://twitter.com/CIT_Bronson)
* Trond Eric Haarvarstein, [@xenappblog](https://twitter.com/xenappblog)

## Versioning

The module uses a version notation that follows: YearMonth.Build. It is expected that the module will have changes on a regular basis, so the version numbering is intended to make it easy to understand when the last update was made.


## Installing the Module

## Install from the PowerShell Gallery

The Evergreen module is published to the PowerShell Gallery and can be found here: [Evergreen](https://www.powershellgallery.com/packages/Evergreen/). The module can be installed from the gallery with:

```powershell
Install-Module -Name Evergreen
Import-Module -Name Evergreen
```

### Updating the Module

If you have installed a previous version of the module from the gallery, you can install the latest update with the `-Force` parameter:

```powershell
Install-Module -Name Evergreen -Force
```

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
