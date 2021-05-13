---
title: "Getting started with Evergreen"
keywords: evergreen
tags: [getting_started]
sidebar: home_sidebar
permalink: index.html
summary: These instructions will help you get started with using Evergreen in software deployments and image creation.
---
Evergreen is a PowerShell module that returns the latest version and download URLs for a set of common Windows applications. The module consists of simple functions to use in scripts when performing several tasks including:

* Retrieve the latest version of an application to compare against a version already installed or downloaded
* Return the URL for the latest version of the application to download it for local installation or deployment to target machines

Evergreen is intended for use in solutions used to automate software deployments. These solutions could be:

* Image creation with Hashicorp Packer - images can be created with the latest version of a set of applications
* Import applications into Microsoft Endpoint Manager - keep Configuration Manager or Microsoft Intune up to date with the latest versions of applications
* Create a library of application installers - by regularly running Evergreen functions, you can retrieve and download the current version of an application and store it in an application directory structure for later use
* Submitting manifests to `Winget` or `Chocolatey` or similar - Evergreen can return an object with a version number and download URL that can be used to construct manifests for the most recent versions

Primary functions in Evergreen are:

* `Get-EvergreenApp` - returns details of the latest release of an application including the version number and download URL
* `Save-EvergreenApp` - simplifies downloading application URLs returned from `Get-EvergreenApp`
* `Find-EvergreenApp` - lists applications supported by the module

## Why

There are several community and commercial products that manage application deployment and updates already. This module isn't intended to compete against those. In fact, they can be complementary - for example, Evergreen can be used with the [Chocolatey Automatic Package Updater Module](https://www.powershellgallery.com/packages/AU/) to find the latest version of an application and then creating and submitting a Chocolatey package, or it can be used to create a [Windows Package Manager](https://github.com/microsoft/winget-cli) manifest (see a sample script here: [New-WinGetManifest.ps1](https://github.com/aaronparker/Evergreen/blob/main/tools/New-WinGetManifest.ps1)).

Evergreen's focus is on integration for PowerShell scripts to provide product version numbers and download URLs. Ideal for use with the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager for operating system deployment, creating applications packages in Microsoft Intune, or with [Packer](https://www.packer.io/) to create evergreen machine images on-premises, in Azure, AWS, or other cloud platforms

## How Evergreen works

{% include important.html content="Application version and download links are only pulled from official sources (vendor web site, GitHub, SourceForge etc.) and never a third party." %}

Evergreen uses an approach that returns at least the version number and download URI for applications programmatically - thus for each run an Evergreen function it should return the latest version and download link.

Evergreen uses several strategies to return the latest version of software:

1. Application update APIs - by using the same approach as the application itself, Evergreen can consistently return the latest version number and download URI - e.g. [Microsoft Edge](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-MicrosoftEdge.ps1), [Mozilla Firefox](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-MozillaFirefox.ps1) or [Microsoft OneDrive](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-MicrosoftOneDrive.ps1). [Fiddler](https://www.telerik.com/fiddler) can often be used to find where an application queries for updates
2. Repository APIs - repo hosts including GitHub and SourceForge have APIs that can be queried to return application version and download links - e.g. [Atom](/Evergreen/Public/Get-Atom.ps1), [Notepad++](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-NotepadPlusPlus.ps1) or [WinMerge](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Public/Get-WinMerge.ps1)
3. Web page queries - often a vendor download pages will include a query that returns JSON when listing versions and download links - this avoids page scraping. Evergreen can mimic this approach to return application download URLs; however, this approach is likely to fail if the vendor changes how their pages work - e.g., [Adobe Acrobat Reader DC](https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Apps/Get-AdobeAcrobatReaderDC.ps1)
4. Static URLs - some vendors provide static or evergreen URLs to their application installers. These URLs often provide additional information in the URL that can be used to determine the application version and can be resolved to the actual target URL - e.g., [Microsoft FSLogix Apps]((https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Apps/Get-MicrosoftFSLogixApps.ps1)) or [Zoom]((https://github.com/aaronparker/Evergreen/blob/main/Evergreen/Apps/Get-Zoom.ps1))

## What Evergreen Doesn't Do

Evergreen does not scape HTML - scraping web pages to parse text and determine version strings and download URLs can be problematic when text in the page changes or the page is out of date. Pull requests that use web page scraping will be closed.

While the use of RegEx to determine application properties (particularly version numbers) is used for some applications, this approach is not preferred, if possible.

For additional applications where the only recourse it to use web page scraping, see the [Nevergreen](https://github.com/DanGough/Nevergreen) project.

{% include links.html %}
