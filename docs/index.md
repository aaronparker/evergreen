---
title: "Getting started with Evergreen"
keywords: evergreen
tags: [getting_started]
sidebar: mydoc_sidebar
permalink: index.html
summary: These instructions will help you get started with using Evergreen in software deployments and image creation.
---

Evergreen is a simple PowerShell module to return the latest version and download URLs for a set of common enterprise Windows applications. The module consists of a number of simple functions to use in scripts when performing several tasks including:

* Retrieve the latest version of a particular application when comparing against a version already installed or downloaded
* Return the URL for the latest version of the application if you need to download it locally for installation or deployment

![leaf by The Icon Z from the Noun Project](/img/EvergreenLeaf.png)

Right now all functions consist of the following:

* `Get` verb - the module provides functions to retrieve data only
* Vendor - the vendor / developer of the application (e.g. `Adobe`, `Google`, `Microsoft`, etc.)
* Product name - product names and optionally version (e.g. `AcrobatReaderDC`, `Chrome`, `VisualStudioCode`, etc.)

This may change in a future release to simplify commands where the application can be a parameter or input into Evergreen to return the details for that application (e.g. `Get-Evergreen -App "MicrosoftEdge"`).

## Why

There are several community and commercial products that manage application deployment and updates already. This module isn't intended to compete against those. In fact, they can be complementary - for example, Evergreen can be used with the [Chocolatey Automatic Package Updater Module](https://www.powershellgallery.com/packages/AU/) to find the latest version of an application and then creating and submitting a Chocolatey package, or it can be used to create a [Windows Package Manager](https://github.com/microsoft/winget-cli) manifest (see a sample script here: [New-WinGetManifest.ps1](/tools/New-WinGetManifest.ps1)).

Evergreen's focus is on integration for PowerShell scripts to provide product version numbers and download URLs. Ideal for use with the Microsoft Deployment Toolkit or Microsoft Endpoint Configuration Manager for operating system deployment, creating applications packages in Microsoft Intune, or with [Packer](https://www.packer.io/) to create evergreen machine images in Azure or AWS.

## How

**Application version and download links are only pulled from official sources (vendor web site, GitHub, SourceForge etc.) and never a third party**.

Wherever possible, Evergeen uses an approach that returns at least the verison number and download URI for applications programatically - thus for each run an Evergreen function it should return the latest version and dowload link.

Scraping web pages to parse text and determine version strings and download URLs can be problematic when text in the page changes or the page is out of date. Evergreen instead uses approaches that should be less prone to failure by querying an API wherever possible. Evergreen uses several strategies to return the latest version of software:

1. Application update APIs - by using the same approach as the application itself, Evergreen can consistently return the latest version number and download URI - e.g. [Microsoft Edge](/Evergreen/Public/Get-MicrosoftEdge.ps1), [Mozilla Firefox](/Evergreen/Public/Get-MozillaFirefox.ps1) or [Microsoft OneDrive](/Evergreen/Public/Get-MicrosoftOneDrive.ps1). [Fiddler](https://www.telerik.com/fiddler) can often be used to find where an application queries for updates
2. Repository APIs - repo hosters including GitHub and SourceForge have APIs that can be queried to return application version and download links - e.g. [Atom](/Evergreen/Public/Get-Atom.ps1), [Notepad++](/Evergreen/Public/Get-NotepadPlusPlus.ps1) or [WinMerge](/Evergreen/Public/Get-WinMerge.ps1)
3. Web page queries - often a vendor download pages will include a query when listing versions and download links - this avoids page scraping. Evergreen can mimic this approach to return application download URLs; however, this approach is likely to fail if the vendor changes how their pages work - e.g. [Microsoft FSLogix Apps](/Evergreen/Public/Get-MicrosoftFSLogixApps.ps1) or [Zoom](/Evergreen/Public/Get-Zoom.ps1)

## PowerShell Support

Evergreen supports Windows PowerShell 5.1 and PowerShell 7.0+. Evergreen should work on PowerShell Core 6.x; however, we are not actively testing on that version of PowerShell, so support cannot be guaranteed.

## Who

This module is maintained by the following community members

* Aaron Parker, [@stealthpuppy](https://twitter.com/stealthpuppy)
* Bronson Magnan, [@CIT_Bronson](https://twitter.com/CIT_Bronson)
* Trond Eric Haarvarstein, [@xenappblog](https://twitter.com/xenappblog)

## Versioning

The module uses a version notation that follows: YearMonth.Build. It is expected that the module will have changes on a regular basis, so the version numbering is intended to make it as simple as possible to understand when the last update was made. See the [CHANGELOG](/CHANGELOG.md) for details on changes introduced in each version.

---
leaf by The Icon Z from the Noun Project

{% include links.html %}
