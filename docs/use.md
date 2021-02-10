---
title: "Using Evergreen"
keywords: evergreen
tags: [use]
sidebar: home_sidebar
permalink: use.html
summary: An introduction on how to use Evergreen in your scripts.
---
Evergreen is intended for use in solutions used to automate software deployments. These solutions could be:

* Image creation with Hashicorp Packer - images can be created with the latest version of a set of applications
* Import applications into Microsoft Endpoint Manager - keep Configuration Manager or Microsoft Intune up to date with the latest versions of applications
* Create a libary of application installers - by regularly running Evergreen functions, you can retrieve and download the current version of an application and store it in an application directory structure for later use
* Submitting manifests to `Winget` or `Chocalatey` or similar - Evergreen can return an object with a version number and download URL that can be used to construct manifests for the most recent versions

## Functions

The Evergreen module include a function per supported application that return objects to the pipeline. Included functions can be viewed with `Get-Command -Module "Evergreen"`. This will return a list of finctions with the following structure:

* `Get` verb - the module provides functions to retrieve data only
* Vendor - the vendor / developer of the application (e.g. `Adobe`, `Google`, `Microsoft`, etc.)
* Product name - product names and optionally version (e.g. `AcrobatReaderDC`, `Chrome`, `VisualStudioCode`, etc.)

For example, Evergreen includes: `Get-AdobeAcrobatReaderDC`, `Get-GoogleChrome`, and `Get-MicrosoftVisualStudioCode`.

{% include note.html content="A future release will simplify commands where the application can be a parameter or input into Evergreen to return the details for that application (e.g. `Get-Evergreen -App MicrosoftEdge`)." %}

## Output

Each Evergreen `Get` function returns at least two properties in the object is sends to the pipeline:

* `Version` - a string property that is the version number of the application. If you need these in a verion format, cast them with `[System.Version]`
* `URI` - a string property that is the download location for the latest version of the application. These will be publically available locations that provide installers in typicaly Windows installer formats, e.g., `exe`, `msi`. Some downloads may be in other formats, such as `zip` that will need to be extracted before install

Several functions may include additional properties in their output, which will often require filtering, including:

* `Architecture` - the processor archiecture of the installer
* `Type` - a function may return installer downloads in `exe`, `msi`, `zip`, format etc. In some instances, `Type` may return slightly different data
* `Ring`, `Channel`, and/or `Release` - some applications include different release rings or channels for enterprise use. The value of this property is often unique to that application
* `Language` - some application installers may support specific lanaguages
* `Date` - in some cases, Evergreen can return the release date of the returned version

### Filter Output

Where a function returns more than one object to the pipeline, you will need to filter the output with `Where-Object` or `Sort-Object`. For example, `Get-MicrosoftTeams` returns both the 32-bit and 64-bit versions of the Microsoft Teams installer. As most environments should be on 64-bit Windows these days, we can filter the 64-bit version of Teams with:

```powershell
Get-MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" }
```

This will return details of the 64-bit Microsoft Teams installer that we can use in a script.

```powershell
Version      : 1.3.00.34662
Architecture : x64
URI          : https://statics.teams.cdn.office.net/production-windows-x64/1.3.00.34662/Teams_windows_x64.msi
```

### Use Output

With the filtered output we can download the latest version of Microsoft Teams before copying it to a target location or installing it directly to the current system. The following commands filters `Get-MicrosoftTeams` to get the latest version and download, then grabs the `Teams_windows_x64.msi` filename from the `URI` property with `Split-Path`, downloads the file locally with `Invoke-WebRequest` and finally uses `msiexec` to install Teams:

```powershell
$Teams = Get-MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" }
$TeamsInstaller = Split-Path -Path $Teams.Uri -Leaf
Invoke-WebRequest -Uri $Teams.Uri -OutFile ".\$TeamsInstaller" -UseBasicParsing
& "$env:SystemRoot\System32\msiexec.exe" "/package $TeamsInstaller ALLUSERS=1 /quiet"
```
