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

### AdobeAcrobatReaderDC

The JSON data returned from the Adobe Acrobat Reader DC download URL (`https://get.adobe.com/reader/webservices/json/standalone/`) returns extraneous data for the following languages, thus they have not been included in the manifest: Portuguese, Chinese (Simplified), Chinese (Traditional)

### MicrosoftSsms

The product release feed used by the Microsoft SQL Server Management Studio (e.g., [https://download.microsoft.com/download/3/f/d/3fd533f5-fdfc-407d-98a6-d5deb214d13b/SSMS_PRODUCTRELEASESFEED.xml](https://download.microsoft.com/download/3/f/d/3fd533f5-fdfc-407d-98a6-d5deb214d13b/SSMS_PRODUCTRELEASESFEED.xml)) includes the internal build number of the SQL Server Management Studio and not the display version, thus the version return will be similar to `15.0.18369.0` instead of the display version: `18.9.1`. See [Download SQL Server Management Studio (SSMS)](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15) for more info.

### VMwareHorizonClient

`VMwareHorizonClient` may not always return the current release - the major version property in the VMware Horizon Client software update data does not use easily sortable versioning.

`VMwareHorizonClient` returns the Horizon Client in .tar format. This the same URL used when the Horizon Client updates itself - you will need to unpack the .tar file to retrieve the executable installer.
