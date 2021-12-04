# Evergreen

![PowerShell Gallery version](https://img.shields.io/powershellgallery/v/Evergreen.svg?style=flat-square)
![PowerShell Gallery downloads](https://img.shields.io/powershellgallery/dt/Evergreen.svg?style=flat-square)

![Evergreen](https://stealthpuppy.com/evergreen/assets/images/evergreenleaf.png){ align=right }

Evergreen is a PowerShell module that returns the latest version and download URLs for a set of common Windows applications. The module consists of simple functions to use in scripts when performing several tasks including:

* Retrieve the latest version of an application to compare against a version already installed or downloaded
* Return the URL for the latest version of the application to download it for local installation or deployment to target machines

Evergreen is intended for use in solutions used to automate software deployments. These solutions could be:

* Image creation with Hashicorp Packer - images can be created with the latest version of a set of applications
* Import applications into Microsoft Endpoint Manager - keep Configuration Manager or Microsoft Intune up to date with the latest versions of applications
* Create a library of application installers - by regularly running Evergreen functions, you can retrieve and download the current version of an application and store it in an application directory structure for later use
* Submitting manifests to `Winget` or `Chocolatey` or similar - Evergreen can return an object with a version number and download URL that can be used to construct manifests for the most recent versions

## Functions

Primary functions in Evergreen are:

* `Get-EvergreenApp` - returns details of the latest release of an application including the version number and download URL
* `Save-EvergreenApp` - simplifies downloading application URLs returned from `Get-EvergreenApp`
* `Find-EvergreenApp` - lists applications supported by the module

## Why

There are several community and commercial products that manage application deployment and updates already. This module isn't intended to compete against those. In fact, they can be complementary - for example, Evergreen can be used with the [Chocolatey Automatic Package Updater Module](https://www.powershellgallery.com/packages/AU/) to find the latest version of an application and then creating and submitting a Chocolatey package, or it can be used to create a [Windows Package Manager](https://github.com/microsoft/winget-cli) manifest (see a sample script here: [New-WinGetManifest.ps1](https://github.com/aaronparker/Evergreen/blob/main/tools/New-WinGetManifest.ps1)).

Evergreen's focus is on integration for PowerShell scripts to provide product version numbers and download URLs. Ideal for use with the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager for operating system deployment, creating applications packages in Microsoft Intune, or with [Packer](https://www.packer.io/) to create evergreen machine images on-premises, in Azure, AWS, or other cloud platforms

[Leaf icon by Icons8](https://icons8.com/icon/S6rvNbebKM9i/leaf)
