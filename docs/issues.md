# Known issues

## General

Where an application source is unavailable the value of the `URI` property returned may be `https://stealthpuppy.com/evergreen/issues/`. If you encounter this scenario, follow [the troubleshooting steps](https://stealthpuppy.com/evergreen/troubleshooting/).

## Public Functions

### Get-EvergreenApp

`Get-EvergreenApp` may not fully support proxy servers. This will be fixed in a future release.

## Private Functions

### Resolve-DnsNameWrapper

Supports Windows platforms only - this function wraps `Resolve-DnsName` which is not available under PowerShell 6+ on macOS or Linux. Application functions that use this private function will return an error on non-Windows platforms.

### Get-GitHubRepoRelease

`Get-GitHubRepoRelease` queries release information from a specified GitHub repository to return version and binaries or is used to source the version number for some applications. This function uses an unauthenticated session to the GitHub REST API, thus requests will be [rate limited]. Using the `-Verbose` parameter with `Get-EvergreenApp` for those applications that use GitHub as the source, will display the number of available requests to the API.

Updating `Get-GitHubRepoRelease` to support authenticated requests is planned for a future release.

## Application Functions

### AdobeAcrobat

Where Adobe releases an update for Acrobat/Reader DC for Windows ahead of macOS, the current patch release may not be returned. In most cases, Adobe keeps both platforms in sync, so this should be a rare occurrence.

The determine the current update version of `AdobeAcrobat`, the [URL for macOS updates](https://armmf.adobe.com/arm-manifests/win/AcrobatDC/acrobat/current_version.txt) is used. This provides a simple text lookup of the latest version number.

!!! info "Note"
    The Windows version of Adobe Acrobat and Reader uses an update URL like: `https://armmf.adobe.com/arm-manifests/win/AcrobatDCManifest3.msi`, which would require unpacking and parsing the MSI file. Sample code to query the MSI database has been posted here: [AdobeReader download links not valid](https://github.com/aaronparker/evergreen/issues/312#issuecomment-1103712904); however, this approach will only work on a Windows hosts and will not support macOS or Linux.

Alternative application - `AdobeAcrobatDC` and `AdobeAcrobatReaderDC` use a web API lookup to determine the current version of Adobe Acrobat Reader DC, Acrobat Standard DC, and Acrobat Pro DC. Earlier version of Acrobat are still affected by this issue.

### AdobeAcrobatReaderDC

`AdobeAcrobatReaderDC` may not return an installer with the [latest update](https://www.adobe.com/devnet-docs/acrobatetk/tools/ReleaseNotesDC/index.html). This application determines the available installers from the [Adobe Acrobat Reader download page](https://get.adobe.com/reader/) - Adobe does not always immediately make the latest update available in the current downloadable installer version.

Validate whether `AdobeAcrobat` returns the latest update version.

### CitrixWorkspaceApp

Citrix occasionally makes changes to the update feed for Citrix Workspace app resulting in the version number and/or the installer URI not returning the correct data. We suspect this issue may be related to Citrix throttling updates for the Citrix Workspace app. The issue with the data source is typically fixed within 72 hours.

When the incorrect data is returned, Evergreen will return data similar to the below.

```powershell
Version : 24.2.0.172
Title   : Citrix Workspace - LTSR
Size    : 380803896
Hash    : 7efe56e0f177cf9de336fa48daa8b6461080909fd37f7d550fd4f313221091b8
Date    : 10/4/2024
Stream  : LTSR
URI     : https://downloadplugins.citrix.com/ReceiverUpdates/Prod/Receiver/Win/CitrixWorkspaceApp24.2.0.172.exe

Version : 0.0.0.0
Title   : Citrix Workspace - Current Release
Size    : 382956344
Hash    : 5c369d1c127b14a8530b7441a6d3ec49c681fe672e8447c63ecf453cf8b87237
Date    : 25/4/2024
Stream  : Current
URI     : https://downloadplugins.citrix.com/ReceiverUpdates/Prod/Receiver/Win/CitrixWorkspaceApp24.3.0.93.exe
```

#### 404 Error

Occasionally `Get-EvergreenApp -Name "CitrixWorkspaceApp"` may fail with the following error:

```powershell
WARNING: Invoke-EvergreenRestMethod: Error at URI: https://downloadplugins.citrix.com/ReceiverUpdates/Prod/catalog_win.xml.
WARNING: Invoke-EvergreenRestMethod: Error encountered: Response status code does not indicate success: 404 (Not Found)..
WARNING: Invoke-EvergreenRestMethod: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
```

This typically occurs right after the release of a new version of the Workspace app and may return this result for some time. Right after a new release of the Workspace app, Citrix often makes the update XML file unavailable so that clients do not update immediately. You may have to wait until Citrix makes the URL available again for this function to work.

#### Out of Date Update Feed

Occasionally `Get-EvergreenApp -Name "CitrixWorkspaceApp"` may not return the latest version of the Citrix Workspace app. This is due to Citrix making changes to the update feed at `https://downloadplugins.citrix.com/ReceiverUpdates/Prod/catalog_win.xml` to throttle or prevent automatic rollout of the latest Workspace app. The only recourse is to wait until Citrix corrects the update feed to include the latest version of the Workspace app again.

### FileZilla

`FileZilla` does not currently return data on PowerShell Core and inconsistently returns data on Windows PowerShell. FileZilla uses a self-signed certificate on their update server and the server uses HSTS, which present some challenges with getting Evergreen to work with the server.

!!! info "Note"
    `FileZilla` has been removed from Evergreen until a better solution can be identified.

### GhislerTotalCommander

This application function works OK without additional requirements on Windows, but requires installation of the `DnsClient-PS` PowerShell module on macOS or Linux.

### LibreOffice

`LibreOffice` uses the update host at `https://update.libreoffice.org/check.php` to determine the available update release. The Document Foundation does not immediately make the update host return the latest version at the time of release. In a scenario where the update host does not return the very latest version and the TDF has pulled the downloads for the same version returned from the update host, `LibreOffice` is unable to build valid download links.

The only recourse at this time is to wait until the TDF tells the update host to return the latest version. Also see [LibreOffice version](https://github.com/aaronparker/evergreen/issues/218)

### Microsoft365Apps

`Microsoft365Apps` returns publicly documented channels only. Additional channels may be available from the Microsoft 365 Apps update API; however, these may not align to channels documented at microsoft.com, so are not included in this function.

Channel properties are listed in the following articles: [Configuration options for the Office Deployment Tool](https://docs.microsoft.com/en-us/deployoffice/office-deployment-tool-configuration-options#channel-attribute-part-of-add-element), [Update channel for Office LTSC 2021](https://docs.microsoft.com/en-us/deployoffice/ltsc2021/update#update-channel-for-office-ltsc-2021), [Update channel for Office 2019](https://docs.microsoft.com/en-us/deployoffice/office2019/update#update-channel-for-office-2019).

Full channel names are listed here: [Update history for Microsoft 365 Apps](https://docs.microsoft.com/en-us/officeupdates/update-history-microsoft365-apps-by-date).

### MicrosoftTeamsClassic

The version number returned by the Microsoft Teams update API may be slightly different to the version number displayed in the `ProductVersion` property in the MSI or in Programs and Features. For example, `Get-EvergreenApp -Name MicrosoftTeams` may report a version number of `1.4.00.8872`, but the Windows Installer may report `1.4.0.8872`. Also see [Get-MicrosoftTeams displays slightly wrong formatted version number](https://github.com/aaronparker/Evergreen/issues/58).

### MicrosoftWvdRemoteDesktop

`MicrosoftWvdRemoteDesktop` may report an HTTP 503 error from some URLs (see an example below). This is intermittent behavior, but the function should still usable data. Suppress this warning with `-WarningAction "SilentlyContinue".

```powershell
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE50Mp8.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
WARNING: Get-MicrosoftWvdRemoteDesktop: Unable to retrieve headers from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE50Mp8.
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE50t3P.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
WARNING: Get-MicrosoftWvdRemoteDesktop: Unable to retrieve headers from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE50t3P.
```

### MozillaFirefox

#### Language Support

`MozillaFirefox` will only return the English US installer by default. This has been done due to the lengthy amount of time that the function takes to query the Mozilla site to find the installers for each channel, architecture and file type. This could be up to 12 objects for each language - if the supported languages are included by default, then the function will take several minutes to return an object.

Any supported language can be passed to `MozillaFirefox` by passing a hashtable to `-AppParams`. For example: `Get-EvergreenApp -Name "MozillaFirefox" -AppParams @{Language="en-GB", "es-ES"}` will return the English (UK) and Spanish language installers for Firefox.

Most [supported languages](https://www.mozilla.org/en-US/firefox/all/#product-desktop-release) can be passed to the function as the language short code. The list of languages can be found in the [MozillaFirefox](https://github.com/aaronparker/evergreen/blob/main/Evergreen/Manifests/MozillaFirefox.json) manifest.

### OBSStudio

Returning the latest version and download for OBS Studio may fail when the OBS Project modifies the availability of the update manifest at `https://obsproject.com/update_studio/manifest.json`. `Get-EvergreenApp -Name OBSStudio` will return a 404 error. The only recourse is to wait until the OBS Project makes the manifest available again.

Evergreen could query versions from the GitHub repository; however, the the OBS Project does not consistently maintain releases in the repository. In some instances a specific release of OBS Studio may address an issue with the macOS version only and `OBSStudio` would then return no results.

Also see [Get-EvergreenApp OBSStudio not working due to a 404 errors](https://github.com/aaronparker/evergreen/issues/184).

### OmnissaHorizonClient

`OmnissaHorizonClient` may not always return the current release - the major version property in the VMware Horizon Client software update data does not use easily sortable versioning. This may be fixed in a future release. Also see [VMware Horizon Client reporting out of date version](https://github.com/aaronparker/Evergreen/issues/161).

### PaintDotNet

`Get-EvergreenApp -Name PaintDotNet` produces the following error under PowerShell on Linux. As a workaround, use `Get-EvergreenApp -Name PaintDotNetOfflineInstaller` instead.

```powershell
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://www.getpaint.net/updates/versions.8.1000.0.x64.en.txt.
WARNING: Invoke-EvergreenWebRequest: Error encountered: The SSL connection could not be established, see inner exception..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
Write-Error: /home/aaron/.local/share/powershell/Modules/Evergreen/2205.561/Apps/Get-PaintDotNet.ps1:20
Line |
  20 |      $Content = Invoke-EvergreenWebRequest -Uri $res.Get.Uri
     |                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Invoke-EvergreenWebRequest: The SSL connection could not be established, see inner exception.
```

### VideoLanVlcPlayer

`VideoLanVlcPlayer` may not always return the latest available release - the release returned by the update feed used by the VLC media player may not be the same as the current version available for download from the [videolan.org](https://www.videolan.org/vlc/) site, due to the version returned in the update feed.

The source code for the update site can be found here: [VideoLAN organization > update.videolan.org > Repository](https://code.videolan.org/VideoLAN.org/update.videolan.org/-/tree/master/vlc).


### VMwareHorizonClientAlt

`VMwareHorizonClient` returns the Horizon Client in .tar format. This the same URL used when the Horizon Client updates itself - you will need to unpack the .tar file to retrieve the executable installer.
