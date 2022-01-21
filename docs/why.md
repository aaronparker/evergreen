# Why

Evergreen's focus is on integration with PowerShell as a simple solution to provide application version numbers and download URLs. This has many use cases, including:

* Importing applications into the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager for operating system deployment
* Creating applications packages in Microsoft Intune or another MDM solution
* Integration with [Azure DevOps](https://stealthpuppy.com/packer/) or [Packer](https://www.packer.io/) to create evergreen machine images on-premises, in Azure, AWS, or other cloud platforms
* Maintaining a library of application install packages to enable roll back or roll forward of application versions in an image
* Audit installed application versions in an image or a Windows desktop

There are several community and commercial solutions that manage application deployment and updates already. This module isn't intended to compete against those, and Evergreen isn't intended to be a fully featured package manager for Windows.

Evergreen can be complementary to 3rd party solutions - for example, Evergreen can be used with the [Chocolatey Automatic Package Updater Module](https://www.powershellgallery.com/packages/AU/) to find the latest version of an application and then create and submit a Chocolatey package, or it can be used to create a [Windows Package Manager](https://github.com/microsoft/winget-cli) manifest (see a sample script here: [New-WinGetManifest.ps1](https://github.com/aaronparker/Evergreen/blob/main/tools/New-WinGetManifest.ps1)).
