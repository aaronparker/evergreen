---
title: "Known Issues"
keywords: evergreen
tags: [issues]
sidebar: home_sidebar
toc: false
permalink: knownissues.html
summary: 
---
## Public Functions

### Get-EvergreenApp

`Get-EvergreenApp` does not fully support proxy servers. This will be fixed in a future release.

### Save-EvergreenApp

The folder structure created by `Save-EvergreenApp` uses a static set of properties from the input object. This path cannot currently by customised by the user.

`Save-EvergreenApp` does not fully support proxy servers. This will be fixed in a future release.

## Application Functions

### 7zip

The 32-bit installers returned by `7Zip` link to a SourceForge download page instead of the file directly.

### AdobeAcrobat

Where Adobe releases an update for Acrobat/Reader for Windows ahead of macOS, the current patch release may not be returned. In most cases, Adobe keeps both platforms in sync, so this should be a rare occurance.

The determine the current update version of `AdobeAcrobat`, the URL for macOS updates is used, for example: [https://armmf.adobe.com/arm-manifests/win/AcrobatDC/acrobat/current_version.txt](https://armmf.adobe.com/arm-manifests/win/AcrobatDC/acrobat/current_version.txt). This provides a simple text lookup of the latest version number.

The Windows version of Adobe Acrobat and Reader uses an update URL like: [https://armmf.adobe.com/arm-manifests/win/AcrobatDCManifest3.msi](https://armmf.adobe.com/arm-manifests/win/AcrobatDCManifest3.msi), which would require unpacking and parsing the MSI file. Doing so may modify the host, so it will not be implemented.

### AdobeAcrobatReaderDC

The JSON data returned from the Adobe Acrobat Reader DC download URL (`https://get.adobe.com/reader/webservices/json/standalone/`) returns extraneous data for the following languages, thus they have not been included in the manifest: Portuguese, Chinese (Simplified), Chinese (Traditional).

### CitrixWorkspaceApp

The version of the HDX RealTime Media Engine for Microsoft Skype for Business for Windows returned by `CitrixWorkspaceApp` is out of date. This is the version of the HDX RTME that is returned by the Workspace App update feed ([https://downloadplugins.citrix.com/ReceiverUpdates/Prod/catalog_win.xml](https://downloadplugins.citrix.com/ReceiverUpdates/Prod/catalog_win.xml)). Use `CitrixWorkspaceAppFeed` to find the latest version of the HDX RTME. Note that returns a link to the download page and not the installer directly.

### MicrosoftSsms

The product release feed used by the Microsoft SQL Server Management Studio (e.g., [https://download.microsoft.com/download/3/f/d/3fd533f5-fdfc-407d-98a6-d5deb214d13b/SSMS_PRODUCTRELEASESFEED.xml](https://download.microsoft.com/download/3/f/d/3fd533f5-fdfc-407d-98a6-d5deb214d13b/SSMS_PRODUCTRELEASESFEED.xml)) includes the internal build number of the SQL Server Management Studio and not the display version, thus the version return will be similar to `15.0.18369.0` instead of the display version: `18.9.1`. See [Download SQL Server Management Studio (SSMS)](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15) for more info.

### VMwareHorizonClient

`VMwareHorizonClient` may not always return the current release - the major version property in the VMware Horizon Client software update data does not use easily sortable versioning.

`VMwareHorizonClient` returns the Horizon Client in .tar format. This the same URL used when the Horizon Client updates itself - you will need to unpack the .tar file to retrieve the executable installer.

### Zoom

`Zoom` returns versions as `Latest` for some downloads - the source used by this function does not provide a method for determining the version number.
