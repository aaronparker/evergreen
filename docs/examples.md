# Example usage

Here's a few examples of using Evergreen functions to return application versions and downloads.

## Microsoft Edge

`Get-EvergreenApp -Name MicrosoftEdge` will return the latest versions and downloads for Microsoft Edge, including Group Policy administrative templates. To return the latest version of Microsoft Edge and the download URI for 64-bit Windows, use the following syntax:

```powershell
Get-EvergreenApp -Name MicrosoftEdge | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" }
```

This will return output similar to the following:

```powershell
Version      : 97.0.1072.69
Platform     : Windows
Channel      : Stable
Release      : Enterprise
Architecture : x64
Date         : 20/1/2022
Hash         : AB27CC051E07ADF4EDD807699541A7516E18C32794272482B7F24ECE18917BE3
URI          : https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/9f730c98-d191-4607-aa1e-e28bd4d9f67e/MicrosoftEdgeEnterpriseX64.msi
```

## Microsoft FSLogix Apps

`Get-EvergreenApp -Name MicrosoftFSLogixApps` will return the latest version and download URI for Microsoft FSLogix Apps. Because the output is simple, no additional filtering is required:

```powershell
Get-EvergreenApp -Name MicrosoftFSLogixApps

Version : 2.9.7654.46150
Date    : 9/1/2021 12:54:48 am
URI     : https://download.microsoft.com/download/4/8/2/4828e1c7-176a-45bf-bc6b-cce0f54ce04c/FSLogix_Apps_2.9.7654.46150.zip
```

## Microsoft Teams

Most Windows desktop environments are going to be on 64-bit Windows, so to get the 64-bit version of Microsoft Teams use the following syntax:

```powershell
Get-EvergreenApp -Name MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" -and $_.Ring -eq "General" -and $_.Type -eq "msi" }
```

## Microsoft OneDrive

`Get-EvergreenApp -Name MicrosoftOneDrive` uses the OneDrive update feed to return version from several release rings - `Enterprise`, `Production` and `Insider`. Often the Production ring returns more than one release:

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
(Get-EvergreenApp -Name MicrosoftOneDrive | Where-Object { $_.Type -eq "Exe" -and $_.Ring -eq "Production" }) | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1
```

## Adobe Acrobat Reader DC

Adobe Acrobat Reader DC returns a large number of languages as well as `x86` and `x64` installers, thus filtering the output is required to return a single installer that might be used in creating a gold image:

```powershell
Get-EvergreenApp -Name AdobeAcrobatReaderDC | Where-Object { $_.Language -eq "English" -and $_.Architecture -eq "x64" }
```

Output should then look similar to the following:

```powershell
Version      : 21.011.20039
Language     : English
Architecture : x64
Name         : Reader DC 2021.011.20039 English Windows(64Bit)
URI          : http://ardownload.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2101120039/AcroRdrDCx642101120039_en_US.exe
```

The installer can then be downloaded with `Save-EvergreenApp`:

```powershell
$Reader = Get-EvergreenApp -Name AdobeAcrobatReaderDC | Where-Object { $_.Language -eq "English" -and $_.Architecture -eq "x64" }
$Reader | Save-EvergreenApp -Path "C:\Temp\Reader"
```

## Mozilla Firefox

`Get-EvergreenApp -Name MozillaFirefox` returns both the current version and extended support release, along with installers in several languages. This means that to return a single version of the Firefox installer, we have a fairly complex query. The example below will return the 64-bit current release of Firefox in the US language and a Windows Installer package. To be doubly sure that we get a single installer, `Sort-Object` is also used to sort the `Version` property and return the most recent:

```powershell
Get-EvergreenApp -Name "MozillaFirefox" -AppParams @{Language="en-GB"} | Where-Object { $_.Channel -eq "LATEST_FIREFOX_VERSION" -and $_.Architecture -eq "x64" -and $_.type -eq "msi" } | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1

Version      : 96.0.2
Architecture : x64
Channel      : LATEST_FIREFOX_VERSION
Language     : en-GB
Type         : msi
Filename     : Firefox Setup 96.0.2.msi
URI          : https://download-installer.cdn.mozilla.net/pub/firefox/releases/96.0.2/win64/en-GB/Firefox%20Setup%2096.0.2.msi
```
