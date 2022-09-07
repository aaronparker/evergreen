# Evergreen

Evergreen is a PowerShell module that returns the latest version and download URLs for a set of common Windows applications. The module consists of simple functions to use in scripts when performing several tasks including:

* Retrieve the latest version of an application to compare against a version already installed or downloaded
* Return the URL for the latest version of the application to download it for local installation or deployment to target machines

Evergreen is intended for use with solutions used to automate software deployments. These solutions could be:

* [Image creation with Hashicorp Packer](https://github.com/aaronparker/packer) - images can be created with the latest version of a set of applications
* Import applications into Microsoft Endpoint Manager - keep Configuration Manager or [Microsoft Intune](https://github.com/aaronparker/packagefactory) up to date with the latest versions of applications
* Validating or auditing a desktop image to ensure the current version of an application is installed
* Create a [library of application installers](https://stealthpuppy.com/apptracker) - by regularly running Evergreen functions, you can retrieve and download the current version of an application and store it in an application directory structure for later use
* Submitting manifests to `Winget` or `Chocolatey` or similar - Evergreen can return an object with a version number and download URL that can be used to construct manifests for the most recent versions

## Functions

Primary functions in Evergreen are:

* `Get-EvergreenApp` - returns details of the latest release of an application including the version number and download URL
* `Save-EvergreenApp` - simplifies downloading application URLs returned from `Get-EvergreenApp`
* `Find-EvergreenApp` - lists applications supported by the module
* `Test-EvergreenApp` - tests that the URIs returned by `Get-EvergreenApp` are valid
* `New-EvergreenLibrary` - creates a new Evergreen library for downloading and maintaining multiple versions of application installers
* `Invoke-EvergreenLibraryUpdate` - updates the application installers stored in an Evergreen library
* `Export-EvergreenApp.ps1` - exports the application version information returned from `Get-EvergreenApp` to a JSON file

[Greentech icon by Icons8](https://icons8.com/icon/BzV6L4Y7vPPZ/greentech)
