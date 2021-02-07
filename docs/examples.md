---
title: "Evergreen examples"
keywords: evergreen
tags: [examples, usage]
sidebar: home_sidebar
permalink: examples.html
summary: How to use sample Evergreen functions in your scripts.
---
Here's a few examples of using `Evergreen` functions to return application versions and downloads.

## Microsoft Edge

`Get-MicrosoftEdge` will return the latest versions and downloads for Microsoft Edge, including Group Policy administrative templates. To return the latest version of Microsoft Edge and the download URI for 64-bit Windows, use the following syntax:

```powershell
Get-MicrosoftEdge | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" }
```

This will return output similar to the following:

```powershell
Version      : 88.0.705.63
Platform     : Windows
Channel      : Stable
Release      : Enterprise
Architecture : x64
Date         : 5/2/2021 6:39:00 pm
Hash         : B6616258484997E8AB77EFCE5C313EDEFD1F056159ACA70156122414C0BD2E60
URI          : https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/e2d06b69-9e44-45e1-bdf5-b3b827fe06b2/MicrosoftEdgeEnterpriseX64.msi
```

## Microsoft FSLogix Apps

`Get-MicrosoftFSLogixApps` will return the latest version and download URI for Microsoft FSLogix Apps:

```powershell
Get-MicrosoftFSLogixApps
```

Because the output is simple, no additional filtering is required:

```powershell
Version : 2.9.7654.46150
Date    : 9/1/2021 12:54:48 am
URI     : https://download.microsoft.com/download/4/8/2/4828e1c7-176a-45bf-bc6b-cce0f54ce04c/FSLogix_Apps_2.9.7654.46150.zip
```

## Microsoft Teams

Most Windows desktop environments are going to be on 64-bit Windows, so to get the 64-bit version of Microsoft Teams use the following syntax:

```powershell
Get-MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" }
```

## Microsoft OneDrive

`Get-MicrosoftOneDrive` uses the OneDrive update feed to return version from several release rings - `Enterprise`, `Production` and `Insider`. Often the Production ring returns more than one release:

```powershell
Version : 21.016.0124.0002
Ring    : Insider
Sha256  : BP/TxWlUFk0rbPVXRlbjYLhddSROtWOFTk7gCK8PWJc=
Type    : Exe
URI     : https://oneclient.sfx.ms/Win/Insiders/21.016.0124.0002/OneDriveSetup.exe

Version : 21.016.0124.0002
Ring    : Insider
Sha256  : N/A
Type    : Msix
URI     : https://oneclient.sfx.ms/Win/Insiders/21.016.0124.0002/Microsoft.OneDriveSyncClient_8wekyb3d8bbwe.msix

Version : 21.002.0104.0005
Ring    : Production
Sha256  : 8xzNz/Yt2ahAc/BZxN5j5gWc7aWypo0A46uUROq8vzg=
Type    : Exe
URI     : https://oneclient.sfx.ms/Win/Prod/21.002.0104.0005/OneDriveSetup.exe

Version : 21.002.0104.0005
Ring    : Production
Sha256  : N/A
Type    : Msix
URI     : https://oneclient.sfx.ms/Win/Prod/21.002.0104.0005/Microsoft.OneDriveSyncClient_8wekyb3d8bbwe.msix

Version : 20.169.0823.0008
Ring    : Enterprise
Sha256  : kDd6mfMp34H7gp4JRBoM//3WNnMZGpz7mba5Ns/OtBs=
Type    : Exe
URI     : https://oneclient.sfx.ms/Win/Enterprise/20.169.0823.0008/OneDriveSetup.exe

Version : 20.169.0823.0008
Ring    : Enterprise
Sha256  : N/A
Type    : Msix
URI     : https://oneclient.sfx.ms/Win/Enterprise/20.169.0823.0008/Microsoft.OneDriveSyncClient_8wekyb3d8bbwe.msix
```

To ensure that we return only the very latest `Production` version, we need to filter the output:

```powershell
(Get-MicrosoftOneDrive | Where-Object { $_.Type -eq "Exe" -and $_.Ring -eq "Production" }) | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1
```

## Adobe Acrobat Reader

Getting the version number and downloads for Acrobat Reader requires some more complex filtering. Adobe provides not only an executable installer but also a Windows Installer patch which you may need to apply to ensure the latest version is installed. The following command will return both the en-US installer and the latest update:

```powershell
Get-AdobeAcrobatReaderDC | Where-Object { $_.Language -eq "English" -or $_.Language -eq "Neutral" }
```

Output should then look similar to the following:

```powershell
Version  : 20.013.20074
Type     : Installer
Language : English
URI      : http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2001320074/AcroRdrDC2001320074_en_US.exe

Version  : 20.013.20074
Type     : Updater
Language : Neutral
URI      : http://ardownload.adobe.com/pub/adobe/reader/win/AcrobatDC/2001320074/AcroRdrDCUpd2001320074.msp
```

When downloading the Adobe Acrobat Reader, this could be taken a step further to unnecessarily downloading the Windows Installer patch if the executable installer is already up to date.

```powershell
$Reader = Get-AdobeAcrobatReaderDC | Where-Object { $_.Language -eq "English" -or $_.Language -eq "Neutral" }
$Installer = ($Reader | Where-Object { $_.Type -eq "Installer" | Sort-Object -Property "Version" -Descending })[-1]
$Updater = ($Reader | Where-Object { $_.Type -eq "Updater" | Sort-Object -Property "Version" -Descending })[-1]
Invoke-WebRequest -Uri $Installer.URI -OutFile (Split-Path -Path $Installer.URI -Leaf) -UseBasicParsing
If ($Updater.Version -gt $Installer.Version) {
    Invoke-WebRequest -Uri $Updater.URI -OutFile (Split-Path -Path $Updater.URI -Leaf) -UseBasicParsing
}
```

## Mozilla Firefox

`Get-MozillaFirefox` returns both the current version and extended support release, along with installers in several languages. This means that to return a single version of the Firefox installer, we have a fairly complex query. The example below will return the 64-bit current release of Firefox in the US langauage and a Windows Installer package. To be doubly sure that we get a single installer, `Sort-Object` is also used to sort the `Version` property and return the most recent:

```powershell
(Get-MozillaFirefox | Where-Object { $_.Channel -eq "LATEST_FIREFOX_VERSION" -and $_.Architecture -eq "x64" -and $_.type -eq "msi" -and $_.Language -eq "en-US" }) | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1
```

{% include links.html %}
