# Why

Evergreen's focus is on integration with PowerShell as a simple solution to provide application version numbers and download URLs. This has many use cases, including:

* Integration with [Azure DevOps](https://stealthpuppy.com/packer/) or [Packer](https://www.packer.io/) to create evergreen machine images on-premises, in Azure, AWS, or other cloud platforms
* Import applications into Microsoft Endpoint Manager - keep the Microsoft Deployment Toolkit, Configuration Manager or [Microsoft Intune](https://github.com/aaronparker/packagefactory) up to date with the latest versions of applications
* Validating or [auditing a desktop image](https://github.com/aaronparker/w365) to ensure the current version of an application is installed
* Audit installed application versions in an image or a Windows desktop
* Create a [library of application installers](https://stealthpuppy.com/evergreen/newlibrary/) - by regularly running Evergreen functions, you can retrieve and download the current version of an application and store it in an application directory structure for later use
* [Track application updates](https://github.com/aaronparker/apptracker) to stay on top of new releases
* Submitting manifests to `Winget` or `Chocolatey` or similar - Evergreen can return an object with a version number and download URL that can be used to construct manifests for the most recent versions

There are several community and commercial solutions that manage application deployment and updates already. This module isn't intended to compete against those, and Evergreen isn't intended to be a fully featured package manager for Windows.

Evergreen can be complementary to 3rd party solutions - for example, Evergreen can be used with the [Chocolatey Automatic Package Updater Module](https://www.powershellgallery.com/packages/AU/) to find the latest version of an application and then create and submit a Chocolatey package, or it can be used to create a [Windows Package Manager](https://github.com/microsoft/winget-cli) manifest (see a sample script here: [New-WinGetManifest.ps1](https://github.com/aaronparker/Evergreen/blob/main/tools/New-WinGetManifest.ps1)).
