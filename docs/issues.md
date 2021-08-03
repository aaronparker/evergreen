# Known issues

## General

Where an application source is unavailable the value of the `URI` property returned may be `https://stealthpuppy.com/evergreen/issues/`. If you encounter this scenario, follow [the troubleshooting steps](https://stealthpuppy.com/evergreen/troubleshooting/).

## Public Functions

### Get-EvergreenApp

`Get-EvergreenApp` does not fully support proxy servers. This will be fixed in a future release.

### Save-EvergreenApp

The folder structure created by `Save-EvergreenApp` uses a static set of properties from the input object. This path cannot currently by customised by the user.

!!! attention "Attention"
    `Save-EvergreenApp` does not fully support proxy servers. This will be fixed in a future release.

## Application Functions

### 7zip

The 32-bit installers returned by `7Zip` link to a SourceForge download page instead of the file directly. These installers can be downloaded by `Invoke-WebRequest` by setting the UserAgent to the [Googlebot](https://github.com/aaronparker/Evergreen/issues/124#issuecomment-839447242).

### AdobeAcrobat

Where Adobe releases an update for Acrobat/Reader for Windows ahead of macOS, the current patch release may not be returned. In most cases, Adobe keeps both platforms in sync, so this should be a rare occurrence.

The determine the current update version of `AdobeAcrobat`, the URL for macOS updates is used: `https://armmf.adobe.com/arm-manifests/win/AcrobatDC/acrobat/current_version.txt`. This provides a simple text lookup of the latest version number.

!!! info "Note"
    The Windows version of Adobe Acrobat and Reader uses an update URL like: `https://armmf.adobe.com/arm-manifests/win/AcrobatDCManifest3.msi`, which would require unpacking and parsing the MSI file. Doing so may modify the host, so it will not be implemented.

### AdobeAcrobatReaderDC

The JSON data returned from the Adobe Acrobat Reader DC download URL (`https://get.adobe.com/reader/webservices/json/standalone/`) returns extraneous data for the following languages, thus they have not been included in the manifest: Portuguese, Chinese (Simplified), Chinese (Traditional).

### Cisco WebEx

The versions returned for Cisco WebEx may be out of date. Refer to [Cisco WebEx - new app available, Evergreen returning legacy version only](https://github.com/aaronparker/evergreen/issues/197) until a fix is found.

### CitrixWorkspaceApp

The version of the HDX RealTime Media Engine for Microsoft Skype for Business for Windows returned by `CitrixWorkspaceApp` is out of date. This is the version of the HDX RTME that is returned by the Workspace App update feed ([https://downloadplugins.citrix.com/ReceiverUpdates/Prod/catalog_win.xml](https://downloadplugins.citrix.com/ReceiverUpdates/Prod/catalog_win.xml)). Use `CitrixWorkspaceAppFeed` to find the latest version of the HDX RTME.

!!! info "Note"
    `CitrixWorkspaceAppFeed` returns a link to the download page and not the installer directly. See [Get-CitrixWorkspaceApp does not return the latest Citrix HDX RealTime Media Engine](https://github.com/aaronparker/Evergreen/issues/59).

### LibreOffice

`LibreOffice` uses the update host at `https://update.libreoffice.org/check.php` to determine the available update release. The Document Foundation does not immediately make the update host return the latest version at the time of release. In a scenario where the update host does not return the very latest version and the TDF has pulled the downloads for the same version returned from the update host, `LibreOffice` is unable to build valid download links. The only recourse is to wait until the TDF tells the update host to return the latest version.

### MicrosoftFSLogixApps

Depending on release schedules, the preview version of the FSLogix Apps download may not be available. The preview version is found here: `https://aka.ms/fslogix/downloadpreview` - if no preview version is behind this URL, `Get-EvergreenApps -Name MicrosoftFSLogixApps` will return an error when attempting to resolve the preview URL, but will continue to return the release version.

### MicrosoftSsms

The product release feed used by the Microsoft SQL Server Management Studio (e.g., [https://download.microsoft.com/download/3/f/d/3fd533f5-fdfc-407d-98a6-d5deb214d13b/SSMS_PRODUCTRELEASESFEED.xml](https://download.microsoft.com/download/3/f/d/3fd533f5-fdfc-407d-98a6-d5deb214d13b/SSMS_PRODUCTRELEASESFEED.xml)) includes the internal build number of the SQL Server Management Studio and not the display version, thus the version return will be similar to `15.0.18369.0` instead of the display version: `18.9.1`. See [Download SQL Server Management Studio (SSMS)](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15) for more info. Also see [SQL SSMS is reporting the wrong version](https://github.com/aaronparker/Evergreen/issues/82).

### Microsoft Teams

The version number returned by the Microsoft Teams update API may be slightly different to the version number displayed in the `ProductVersion` property in the MSI or in Programs and Features. For example, `Get-EvergreenApp -Name MicrosoftTeams` may report a version number of `1.4.00.8872`, but the Windows Installer may report `1.4.0.8872`. Also see [Get-MicrosoftTeams displays slightly wrong formatted version number](https://github.com/aaronparker/Evergreen/issues/58).

### OBS Studio

Returning the latest version and download for OBS Studio may fail when the OBS Project modifies the availability of the update manifest at `https://obsproject.com/update_studio/manifest.json`. `Get-EvergreenApp -Name OBSStudio` will return a 404 error. The only recourse is to wait until the OBS Project makes the manifest available again.

Evergreen could query versions from the GitHub repository; however, the the OBS Project does not consistently maintain releases in the repository. In some instances a specific release of OBS Studio may address an issue with the macOS version only and `OBSStudio` would then return no results.

Also see [Get-evergreenapp OBSStudio not working due to a 404 errors](https://github.com/aaronparker/evergreen/issues/184).

### VMwareHorizonClient

`VMwareHorizonClient` may not always return the current release - the major version property in the VMware Horizon Client software update data does not use easily sortable versioning. This may be fixed in a future release. Also see [VMware Horizon Client reporting out of date version](https://github.com/aaronparker/Evergreen/issues/161).

!!! info "Note"
    `VMwareHorizonClient` returns the Horizon Client in .tar format. This the same URL used when the Horizon Client updates itself - you will need to unpack the .tar file to retrieve the executable installer.

### Zoom

`Zoom` returns versions as `Latest` for some downloads - the source used by this function does not provide a method for determining the version number. Also see [Zoom currently failing](https://github.com/aaronparker/Evergreen/issues/200)
