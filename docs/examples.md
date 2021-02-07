---
title: "Evergreen examples"
keywords: evergreen
tags: [getting_started]
sidebar: mydoc_sidebar
permalink: examples.html
summary: Evergreen example commands.
---

Here's a few examples of using `Evergreen` functions to return application versions and downloads.

## Microsoft Edge

`Get-MicrosoftEdge` will return the latest versions and downloads for Microsoft Edge on Windows and macOS, including Group Policy administrative templates. To return the latest version of Microsoft Edge and the download URI for 64-bit Windows, use the following syntax:

```powershell
$Edge = Get-MicrosoftEdge | Where-Object { $_.Architecture -eq "x64" -and $_.Product -eq "Stable" -and $_.Platform -eq "Windows" }
$Edge | Sort-Object -Property Version -Descending | Select-Object -First 1
```

This will return output similar to the following:

```powershell
Version      : 79.0.309.71
Platform     : Windows
Product      : Stable
Architecture : x64
Date         : 21/1/20 8:59:00 pm
Hash         : 7E91F560469806F3842B16E185241BBAE82714A86808507FA23A4312EA1E0C11
URI          : http://dl.delivery.mp.microsoft.com/filestreamingservice/files/07367ab9-ceee-4409-a22f-c50d77a8ae06/MicrosoftEdgeEnterpriseX64.msi
```

## Microsoft FSLogix Apps

`Get-MicrosoftFSLogixApps` will return the latest version and download URI for Microsoft FSLogix Apps:

```powershell
Get-MicrosoftFSLogixApps
```

Because the output is simple, no additional filtering is required:

```powershell
Version        URI
-------        ---
2.9.7237.48865 https://download.microsoft.com/download/3/d/d/3ddfe262-56c7-496c-9af6-82602d2d7b5d/FSLogix_Apps_2.9.7237.48865.zip
```

## Microsoft Teams

Most Windows desktop environments are going to be on 64-bit Windows, so to get the 64-bit version of Microsoft Teams use the following syntax:

```powershell
Get-MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" }
```

## Adobe Acrobat Reader

Getting the version number and downloads for Acrobat Reader requires some more complex filtering. Adobe provides not only an executable installer but also a Windows Installer patch which you may need to apply to ensure the latest version is installed. The following command will return both downloads:

```powershell
Get-AdobeAcrobatReaderDC | Where-Object { $_.Platform -eq "Windows" -and ($_.Language -eq "English" -or $_.Language -eq "Neutral") }
```

Output should then look similar to the following:

```powershell
Version  : 19.021.20058
Platform : Windows
Type     : Installer
Language : English
URI      : http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1902120058/AcroRdrDC1902120058_en_US.exe

Version  : 19.021.20061
Platform : Windows
Type     : Updater
Language : Neutral
URI      : http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/1902120061/AcroRdrDCUpd1902120061.msp
```

{% include links.html %}
