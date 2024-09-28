# Evergreen

Evergreen is a PowerShell module that returns the latest version and download links for a set of common Windows applications.

## Trust

The goal of this project is to provide trust. Evergreen executes in your environment and queries application vendor sources only. To find application versions, Evergreen queries the same update APIs used by the application to find new updates or a source owned by the vendor. This means that you can trust what Evergreen returns because there is no middle man.

## Why

Evergreen helps solve several challenges including:

* Finding the latest version of an application to compare against a version already installed or downloaded
* Finding the URL for the latest application installer to download it for local installation (via scripted install or in a gold image) or deployment to target machines (e.g. Intune or ConfigMgr)

Evergreen helps to automate software deployments. These could be:

* Gold image creation with Hashicorp Packer - images can be created with the latest version of a set of applications
* Import applications into the Microsoft Deployment Toolkit, Configuration Manager or [Microsoft Intune](https://github.com/aaronparker/packagefactory) - stay current with the latest versions of applications
* Validating or auditing a Windows image or machine for installed application versions
* Create a [library of application installers](https://stealthpuppy.com/apptracker) - by regularly running Evergreen functions, you can retrieve and download the current version of an application and store it for later use
* Submitting manifests to `Winget` or `Chocolatey` or similar - Evergreen can return an object with a version number and download URL that can be used to construct manifests for the most recent versions

There are several community and commercial solutions that manage application deployment and updates already. This module isn't intended to compete against those, and Evergreen isn't intended to be a fully featured package manager for Windows. Evergreen can be complementary to 3rd party solutions

## Functions

Primary functions in Evergreen are:

* `Get-EvergreenApp` - returns details of the latest release of an application including the version number and download URL for supported applications. Runs in your environment
* `Save-EvergreenApp` - simplifies downloading application installers returned from `Get-EvergreenApp`
* `Get-EvergreenEndpointFromApi` - returns details of the latest release of an application including the version number and download URL from the Evergreen API
* `Find-EvergreenApp` - lists applications supported by the module
* `Test-EvergreenApp` - tests that the URIs returned by `Get-EvergreenApp` are valid
* `New-EvergreenLibrary` - creates a new Evergreen library for downloading and maintaining multiple versions of application installers
* `Start-EvergreenLibraryUpdate` - updates the application installers and database of apps stored in an Evergreen library
* `Get-EvergreenAppFromLibrary` - returns details of applications stored in an Evergreen library
* `Export-EvergreenApp.ps1` - exports the application version information returned from `Get-EvergreenApp` to a JSON file
* `Get-EvergreenEndpointFromApi` - returns the list of endpoints used by Evergreen that can be imported into a firewall or proxy server allow list

[Greentech icon by Icons8](https://icons8.com/icon/BzV6L4Y7vPPZ/greentech)
