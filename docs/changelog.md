---
title: "Evergreen change log"
keywords: evergreen
tags: [changelog]
sidebar: home_sidebar
toc: false
permalink: changelog.html
summary: Changes, updates, fixes and breaking changes in each Evergreen version.
---
## 2103.298

* Adds `Get-MicrosoftAzureDataStudio`, `Get-ControlUpConsole`
* Updates `Get-ControlUpAgent` to use the published JSON at [https://www.controlup.com/latest-agent-console/](https://www.controlup.com/latest-agent-console/) - the last vestiges of any screen scraping code have been swept away
* Updates `Get-AdobeAcrobatReaderDC` to account for the new 64-bit version of Reader to add [#121](https://github.com/aaronparker/Evergreen/issues/121). Filter with `Where-Object` to return the required version, language and architecture
* BREAKING CHANGES
  * Adds `Architecture` property and removes `Type` property from the output of `Get-AdobeAcrobatReaderDC`
  * Removes the Adobe Acrobat Reader DC updaters from `Get-AdobeAcrobatReaderDC` as there is no consistent automated method to determine whether an update is required or optional
  * Changes the output of `Get-ControlUpAgent` - the values in the `Framework` property have changed and the function only returns the most recent agent version

## 2102.291

* Renames function `Get-AdobeAcrobatProDC` to `Get-AdobeAcrobat` and includes support for returning updates for Adobe Acrobat Pro/Standard DC, 2020, 2017, and 2015. Addresses [#114](https://github.com/aaronparker/Evergreen/issues/114)
  * Alias `Get-AdobeAcrobatProDC` included for backward compatibility
* Adds `Preview` ring to `Get-MicrosoftTeams`
* Updates function comment-based help and corrects spelling across several functions
* BREAKING CHANGES
  * Adds `Track` property to `Get-AdobeAcrobat` with values of `DC`, `2020`, `2017`, `2015` - filter with `Where-Object`
  * Adds `Ring` property to `Get-MicrosoftTeams` for `General` (i.e. current / production ring) and `Preview` rings - filter with `Where-Object`

## 2102.286

* Adds the `ARM` architecture to `Get-MicrosoftVisualStudioCode`
* Updates `Get-MicrosoftWvdRemoteDesktop` to output the `URI` property value in the format `https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4MntQ` instead of the original fwlink source URL (e.g. `https://go.microsoft.com/fwlink/?linkid=2068602`)
* Updates the following functions to use `Invoke-RestMethod` (via `Invoke-RestMethodWrapper`) instead of `Invoke-WebRequest` to simplify code and fix an issue where some functions where returning `Version` as a PSObject instead of System.String ([#109](https://github.com/aaronparker/Evergreen/issues/109))
  * `Get-AtlassianBitbucket`, `Get-Cyberduck`, `Get-FileZilla`, `Get-Fork`, `Get-RingCentral`, `Get-ScooterBeyondCompare`, `Get-SumatraPDFReader`, `Get-VideoLanVlcPlayer`
* Updates module `ReleaseNotes` location to: [https://stealthpuppy.com/Evergreen/changelog.html](https://stealthpuppy.com/Evergreen/changelog.html)

## 2101.281

* Renames `Get-MicrosoftOffice`, to `Get-Microsoft365Apps` to align with product name. The alias `Get-MicrosoftOffice` is included for backward compatibility
* Adds the `Monthly Enterprise` channel to `Get-Microsoft365Apps` output. See [#107](https://github.com/aaronparker/Evergreen/issues/107)
* Adds private function `Invoke-RestMethodWrapper` to enable normalisation across public functions and PowerShell/Windows PowerShell that use `Invoke-RestMethod`
  * Updates private function `Get-GitHubRepoRelease` to use `Invoke-RestMethodWrapper`
  * Updates several public functions to use `Invoke-RestMethodWrapper` instead of the previous method of `Invoke-WebRequest | ConvertTo-Json` - `Get-1Password`, `Get-CitrixVMTools`, `Get-FoxitReader`, `Get-GoogleChrome`, `Get-Microsoft365Apps`, `Get-MicrosoftEdge`, `Get-MicrosoftTeams`, `Get-MicrosoftVisualStudioCode`, `Get-MozillaFirefox`, `Get-MozillaThunderbird`
  * Updates public functions that used `Invoke-RestMethod` to use `Invoke-RestMethodWrapper` instead - `Get-Gimp`, `Get-MicrosoftPowerShell`, `Get-MicrosoftVisualStudio`
* Renames private function `Invoke-WebContent` to `Invoke-WebRequestWrapper` and makes general improvements to the handling of `Invoke-WebRequest`
* Renames private function `ConvertFrom-SourceForgeReleasesJson` to `Get-SourceForgeRepoRelease`
  * Updates and optimises this function to make use of `Invoke-RestMethodWrapper` so that it can query a SourceForge repository and return the required output in a single function
  * Simplifies code in public functions that return SourceForge releases - `Get-7zip`, `Get-KeePass`, `Get-PDFForgePDFCreator`, `Get-ProjectLibre`, `Get-WinMerge`, `Get-WinSCP`
* Renames private functions for more descriptive function names (these resolve HTTP 301/302 return codes):
  * `Resolve-Uri` to `Resolve-SystemNetWebRequest`
  * `Resolve-RedirectedUri` to `Resolve-InvokeWebRequest`
* BREAKING CHANGES
  * Removes parameter from several functions (below) to simplify existing functions and support a move to a single `Get-EvergreenApp` function
  * Removes the `-Channel` and `-Platform` parameters from `Get-MicrosoftVisualStudioCode`. Filter output using `Where-Object` on the `Channel` and `Platform` parameters on the function output
  * Removes the `-Language` parameter from `Get-MozillaFirefox` and `Get-MozillaThunderbird`. Filter output using `Where-Object { $_.Language -eq "en-US" }` or similar. These functions will return the following languages (for additional languages, please open an issue on the project): `en-US`, `en-GB`, `en-CA`, `es-ES`, `sv-SE`, `pt-BR`, `pt-PT`, `de`, `fr`, `it`, `ja`, `nl`, `zh-CN`, `zh-TW`, `ar`, `hi-IN`, `ru`

## 2101.275

* Adds `Get-AtlassianBitbucket`, `Get-TelegramDesktop`, `Get-Gimp`, `Get-BitwardenDesktop`, `Get-MicrosoftBicep`
* Updates `Get-MicrosofPowerShell` to return both the `Stable` and `LTS` releases of PowerShell
* BREAKING CHANGES
  * Update output of `Get-MicrosoftOneDrive` - changes property `Sha256Hash` to `Sha256` to be consistent with other functions
  * Adds a `Release` property to the output of `Get-MicrosofPowerShell` - use `Where-Obect` to filter on `Stable` or `LTS`

## 2101.263

* Adds `Get-AdobeBrackets`, `Get-Fork`, `Get-MicrosoftVisualStudio`, `Get-VercelHyper`
* Updates manifest for `MicrosoftWvdRemoteDesktop` to ensure evergreen source URLs used for resolving downloads
* Updates manifest for `MicrosoftVisualStudioCode`

## 2101.256

* Adds `Get-Terminals`, `Get-PeaZipPeaZip`, `Get-Slack`, `Get-MicrosoftWindowsPackageManagerClient`, `Get-KeePassXCTeamKeePassXC`, `Get-SumatraPDFReader`
* Renames `Get-Atom`, to `Get-GitHubAtom` to better align with vendor name. The alias `Get-Atom` is included for backward compatibility
* Fixes an issue with `Get-AdobeAcrobatReaderDC` - Adobe doesn't use HTTPS with their download locations yet. See [#99](https://github.com/aaronparker/Evergreen/issues/99)
* Updates `Get-AdobeAcrobatReaderDC` to simplify code and better align manifest with standard structure

## 2101.249

* Adds `Get-MicrosoftWvdRemoteDesktop`, `Get-MozillaThunderbird`, `Get-ProjectLibre`, `Get-RingCentral`, `Get-RCoreTeamRforWindows`, `Get-StefansToolsgregpWin`
* Renames `Get-MicrosoftPowerShellCore` to `Get-MicrosoftPowerShell` - PowerShell Core was renamed to PowerShell with the release of PowerShell 7.0. The alias `Get-MicrosoftPowerShellCore` is included for backward compatibility
* Fixes an issue with `Get-GitHubRelease` that ignored anything passed to the `-Uri` parameter
* Adds the MSIX format to the output of `Get-MicrosoftOneDrive` - filter output with the `Type` property (I'm not really sure how useful MSIX format for the OneDrive client is right now though...)
* Adds the VboxGuestAdditions ISO to the output of `Get-OracleVirtualBox` - filter output with the `Type` property
* Refactors `Get-Zoom` to simplify function code and improve output
* Updates version output for `Get-MicrosoftWvdRtcService` and `Get-MicrosoftWvdInfraAgent`
* Updates manifest for a number of functions to better align with an updated standard structure (see `Manifests/Template.json`)
* BREAKING CHANGES:
  * Output of `Get-MicrosoftOneDrive` has changed - `Platform` has been removed and `Type` has been added
  * Output of `Get-OracleVirtualBox` has changed - `Type` property has been added
  * Output of `Get-Zoom` has changed - filter output with the `Platform` and `Type` properties

## 2012.242

* Adds `Get-AdobeAcrobatProDC`, `Get-TelerikFiddlerEverywhere`, `Get-1Password`
* Adds Windows Installer downloads ouput to `Get-FoxitReader`
* Updates `Get-MicrosoftSsms` to query an evergreen update URL to gather new versions from the product releases feed
  * NOTE: the version of SSMS in the releases feed is not the actual current release version - we can only work with what the feed returns; See [#82](https://github.com/aaronparker/Evergreen/issues/82)
* Updates `Get-MicrosoftSsms` to output all supported languages for downloads - filter output on the `Language` property
* Updates `Get-MozillaFirefox` to return both Exe and Msi versions of the Firefox installer
* Adds SHA256 hash property to output from `Get-MicrosoftVisualStudioCode`
* Fixes an issue with the `URI` output in `Get-Cyberduck` that was returning an additional `/` character
* Refactors private function to query the GitHub releases API (`Get-GitHubRepoRelease`, replacing `ConvertFrom-GitHubReleasesJson`) to use `Invoke-RestMethod` for simpler public functions used to return GitHub releases
* Updates the following functions to use `Get-GitHubRepoRelease` - `Get-Atom`, `Get-AdoptOpenJdk`, `Get-BISF`, `Get-dnGrep`, `Get-GitForWindows`, `Get-GitHubRelease`, `Get-Greenshot`, `Get-Handbrake`, `Get-MicrosoftPowerShellCore`, `Get-MicrosoftPowerToys`, `Get-mRemoteNG`, `Get-NotepadPlusPlus`, `Get-OpenJDK`, `Get-OpenShellMenu`, `Get-ShareX`, `Get-Win32OpenSSH`, `Get-WixToolSet`
* Updates manifest for a number of functions to better align with an updated standard structure (see `Manifests/Template.json`)
* Updates private function `ConvertTo-DateTime` to better handle date/time format conversion. Still some improvements to be made here
* BREAKING CHANGES:
  * Updates `Get-OpenJDK` to return only Msi releases and removes Debug, zip etc. On-going improvements - see [#76](https://github.com/aaronparker/Evergreen/issues/76)
  * Removes Beta and Snapshots releases from `Get-Cyberduck`
  * Removes Debug releases from `Get-Greenshot`
  * Removes SafeMode releases from `Get-Handbrake`
  * Removes Beta channel and ARM64 releases from `Get-MicrosoftEdge`
  * Removes Zip format releases from `Get-MicrosoftPowerShellCore`
  * Removes Symbols releases from `Get-Win32OpenSSH`

## 2012.225

* Adds `Get-Microsoft.NET` (.NET 5.0 and .NET Core), `Get-Win32OpenSSH`, `Get-MicrosoftPowerToys`
* Updates `Get-OpenJDK` to return all releases. Further filtering will be added in the future per [#76](https://github.com/aaronparker/Evergreen/issues/76)
* Updates `Get-MozillaFirefox` to resolve download URIs for both EXE and MSI Firefox installers and updates output with additional properties (`Architecture`, `Channel` and `Type`). See [#83](https://github.com/aaronparker/Evergreen/issues/83).
  * Note: this introduces a breaking change - the `-Platform` switch has been removed, you will need to filter the output on the `Architecture` property
* Updates `Get-AdobeAcrobatReader` to return additional languages [#84](https://github.com/aaronparker/Evergreen/issues/84). Note that Reader DC does not provide the latest version for all languages - it may be a better approach to use the [MUI version of the Reader installer](https://helpx.adobe.com/au/reader/faq.html#Enterprisedeployment) if your language is supported

## 2010.219

* Update `Get-FileZilla` to fix invalid download URI returned from the FileZilla update feed. Fix [#75](https://github.com/aaronparker/Evergreen/issues/75)
* Update `Get-Cyberduck` to remove code that replaces `//` with `/`. Returns unfiltered URL from Cyberduck update feed. Fix [#75](https://github.com/aaronparker/Evergreen/issues/75)

## 2009.218

* Fix `Get-FoxitReader` with changes to download page in `FoxitReader.json`. Address [#72](https://github.com/aaronparker/Evergreen/issues/72)
* Fix `Get-Zoom` with changes to resolved URIs. Address [#73](https://github.com/aaronparker/Evergreen/issues/73)
* Update `MicrosoftWvdRtcService.json` to new version of the Microsoft Remote Desktop WebRTC Redirector Service
* Update `Resolve-Uri` with additional verbose output

## 2006.212

* Renames `Get-CitrixXenServerTools` to `Get-CitrixVMTools` and adds `Get-CitrixXenServerTools` alias
* Updates `Get-CitrixVMTools` with new release URL for v7 updates and add v9 updates
* Updates install command lines for `Get-CitrixVMTools`
* Adds `Get-AdoptOpenJDK` - closes [#69](https://github.com/aaronparker/Evergreen/issues/69)

## 2006.207

* Fix path in downloads from apps hosted on Source Forge returned in `ConvertFrom-SourceForgeReleasesJson.ps1`. Fixes [#67](https://github.com/aaronparker/Evergreen/issues/67)
* Update `Get-MozillaFirefox` to return Extended Support Release as well as Current Release. Address [#61](https://github.com/aaronparker/Evergreen/issues/61)
* Update manifests to address [#57](https://github.com/aaronparker/Evergreen/issues/57) [#54](https://github.com/aaronparker/Evergreen/issues/54) [#53](https://github.com/aaronparker/Evergreen/issues/53) [#52](https://github.com/aaronparker/Evergreen/issues/52)

## 2006.203

* Removes Size property from `Get-FoxitReader` because this isn't being gathered consistently for each download
* Updates version / releases feed for `Get-MicrosftSsms` to ensure the current version is returned
* Updates the way private function `ConvertFrom-SourceForgeReleasesJson` returns available downloads from SourceForge
* Updates `Get-7zip`, `Get-KeePass`, `Get-PDFForgePDFCreator` and `Get-WinMerge` to support new approach to retrieving SourceForge downloads

## 2005.190

* Adds `Get-MicrosoftWvdBootLoader` - Get the filename and download URL for the Microsoft Windows Virtual Desktop Remote Desktop Boot Loader
* Updates `Get-FoxitReader` to sort release versions correctly and return latest (v10.x)

## 2005.187

* Adds `Get-MicrosoftWvdRtcService` - returns the version, filename and download for the Microsoft Remote Desktop WebRTC Redirector service for Windows Virtual Desktop

## 2005.183

* Updates `Get-VMwareTools` to return the very latest version with updated download URL
* Adds `Get-WixToolset`

## 2005.176

* Fixes an issue where `Get-MicrosoftEdge` was only returning ARM64 downloads
* Updates `Get-MicrosoftEdge` to only return downloads for the Enterprise ring (removed Consumer ring)
* Fixes an issue with `Get-MicrosoftTeams` where it was returning an incorrect download URL

## 2005.172

* Updates `Get-MicrosoftEdge` to correctly return the latest version and policy files for the Enterprise ring
* Updates output for private function `Resolve-Uri` with addition properties
* Updates `Get-FoxitReader`, `Get-MicrosoftFSLogixApps`, and `Get-MicrosoftSsms` to use `Resolve-Uri` instead of `Resolve-RedirectedUri` for improved performance
* Updates `Get-LibreOffice` to retrieve latest version from the update API instead of page scraping
* Updates private function `ConvertTo-DateTime` with improvements in returning localised date (so the rest of us don't need to be stuck with US date formats)
* Aligns `Get-NotepadPlusPlus` with private function `ConvertFrom-GitHubReleasesJson` to return GitHub release data
* Fixes output in `Get-VMwareTools` to ensure correct version and download URL are returned
* Adds date to output in several functions
* General code and inline help improvements
* Adds module icon for display in the PowerShell Gallery

## 2004.161

* Updates `Get-MicrosoftEdge` with the following:
  * Returns Edge for Windows only
  * Removes `-Channels` and `-Platforms` parameters. Filter output with `Where-Object` instead
  * Returns these channels and downloads only `Stable`, `Beta`, `EdgeUpdate`, and `Policy` (administrative templates)
  * Filters and returns only the latest version of each of the above channels and downloads
  * Output includes `Channel` (Stable, Beta etc.) and `Release` (Enterprise, Consumer) to enable filtering

## 2004.157

* Adds `Get-MicrosoftWvdInfraAgent`
* Adds `Get-dnGrep`
* Recode of `Get-PaintDotNet` (or how did I not know about `ConvertFrom-StringData` before?)
* To simplify output, removes Linux, macOS output from `Get-CitrixWorkspaceApp`, `Get-GoogleChrome`, `Get-OracleVirtuaBox`, `Get-LibreOffice`, `Get-MicrosoftVisualStudioCode`, `Get-MozillaFirefox`, `Get-OracleVirtualBox`, `Get-TeamViewer`
* Updates RegEx method to extract version across various functions to simplify code
* Splits Pester tests for Public functions to allow for faster local testing

## 2004.147

* Adds `Get-Handbrake`, `Get-KeePass`, `Get-OpenShellMenu`, `Get-VastLimitsUberAgent`, `Get-WinSCP`
* Removes macOS and Linux output from `Get-AdobeAcrobatReader`, `Get-LibreOffice`
* Filters macOS and Linux output from private function `ConvertFrom-GitHubReleasesJson.ps1`
* Fixes spaces in private function `ConvertFrom-SourceForgeReleasesJson`

## 2004.141

* Adds private function `ConvertFrom-SourceForgeReleasesJson` to convert JSON release info from SourceForge projects and simplify adding additional functions that pull release info from SourceForge projects. Release information is limited by what's provided from SourceForge
* Updates `Get-WinMerge` to use `ConvertFrom-SourceForgeReleasesJson`
* Adds `Get-7Zip`, `Get-PDFForgePDFCreator`
* Renames `-TrustCertificate` parameter in private function `Invoke-WebContent` to `-SkipCertificateCheck` to align with `-SkipCertificateCheck` available in '`Invoke-WebRequest` in PowerShell Core
* Enables `-SkipCertificateCheck` for both PowerShell Core and Windows PowerShell in `Invoke-WebContent`. Previously supported Windows PowerShell only
* Improves code in `Invoke-WebContent`
* Adds `-Uri` parameter validation in `Get-GitHubRelease` to ensure valid GitHub URLs are passed to the function
* Sets function global `ErrorPreference` to `Stop` to ensure better exception output from functions in the event of failures

## 2004.139

* Adds `ConvertFrom-GitHubReleasesJson` to standardise queries to GitHub repositories
* Updates `Get-Atom`, `Get-BISF`, `Get-GitForWindows`, `Get-Greenshot`, `Get-MicrosoftPowerShellCore`, `Get-OpenJDK`, `Get-ShareX`, `Get-mRemoteNG` to use `ConvertFrom-GitHubReleasesJson`
* Updates RegEx for version matching strings for `BISF`, `GitForWindows`, `ShareX`
* Adds `Get-Architecture` and `Get-Platform` private functions
* Adds `Get-GitHubRelease` to enable returning version and downloads from any GitHub repository. Use to get versions of applications on GitHub that aren't yet included in `Evergreen`

## 2004.134

* Fixes an issue where `Get-Zoom` was still returning a URI to downloads with query strings attached.

## 2004.133

* Updates URL to current version for `TeamViewer`. New URL requires different approach to query
* Adds `Invoke-SystemNetRequest` that uses `System.Net.WebRequest` to make a HTTP request and return response
* Updates `Get-TeamViewer` to use `Invoke-SystemNetRequest` to retrieve version from updated URL. Updates code to return version and download URL as a result
* Updates `Get-Zoom` to use `Resolve-Uri` to follow download URLs and find version number. `Get-Zoom` now returns more versions numbers for Zoom downloads than previously. Updates RegEx approach that returns version numbers from download URLs

## 2004.126

* Adds back `Get-FileZilla` using the application update API. Currently returns only the 64-bit version of FileZilla for Windows.

## 2004.125

* Adds `Get-MicrosoftOneDrive`. We recommend validating versions returned by this function with [OneDrive release notes](https://support.office.com/en-us/article/onedrive-release-notes-845dcf18-f921-435e-bf28-4e24b95e5fc0)
* Removes `Get-FileZilla` until a more robust process to return versions and download can be created
* Removes progress bar for `Invoke-WebRequest` for faster query of APIs
* Updates `Get-NotepadPlusPlus` to use the GitHub releases API to find new versions as the application update API can be out of date

## 2002.120

* Updates `Get-GitForWindows` to return correct version number
* Updates `Get-Zoom` to return version number correctly
* Adds `Resolve-Uri` with a new method of returning redirects from 301/302 via @iainbrighton

## 2001.117

* Updates `Get-FileZilla` to return 32-bit and 64-bit download URIs

## 2001.110

* Adds `Get-MicrosoftTeams`
* Update error handling in `Get-VideoLanVlcPlayer`

## 2001.104

* Adds `Get-MicrosoftEdge` for the new Chromium based Microsoft Edge
* Additional verbose output in `Invoke-WebContent`

## 1911.101

* Adds `Get-ScooterBeyondCompare`
* Updates XML parsing approach in `Get-CitrixRssFeed`, `Get-CitrixWorkspaceApp`, `Get-NotepadPlusPlus`, `Get-VideoLanVlcPlayer`

## 1911.97

* Adds private function `Resolve-RedirectedUri` to handle resolving 301/302 redirects on PowerShell Core and Windows PowerShell
* Updates `Get-VideoLanVlcPlayer`, `Get-MicrosoftSsms`, `Get-FoxitReader`, `Get-MicrosoftFSLogixApps`, `Get-Zoom` with full support for PowerShell Core
* Updates logic to filter out prerelease assets in `Get-Atom`, `Get-BISF`, `Get-GitForWindows`, `Get-Greenshot`, `Get-MicrosoftPowerShellCore`, `Get-OpenJDK`, `Get-ShareX`, `Get-mRemoteNG`
* Prevents `Get-MicrosoftSsms`, `Get-CitrixRssFeed`, `Get-Cyberduck`, `Get-OracleJava8` from throwing on error
* Updates to application manifests with some work on silent install commands

## 1911.95

* Adds `Get-MicrosoftFSLogixApps`

## 1911.93

* Fixes version match in `Get-ControlUpAgent`

## 1911.91

* Adds `Get-Cyberduck`

## 1911.87

* Adds `Get-JamTreeSizeFree` and `Get-JamTreeSizeProfessional`
* Fixes URL to [Release notes / CHANGELOG](https://github.com/aaronparker/Evergreen/blob/master/CHANGELOG.md) in module manifest

## 1911.84

* Changes approach used in `Get-ControlUpAgent` to retrieve agent details and enables PowerShell Core support
* Implemented per-application manifests (URLs, RegEx, strings etc.) for simpler function management
* Adds `Export-EvergreenFunctionStrings` to export per-application manifests
* Renames function `Get-Java8` to `Get-OracleJava8`
* Adds Pester tests for Public functions to ensure URI properties are valid

## 1911.75

* Updates `Get-LibreOffice` update query approach to provide a more consistent output
* Updates `Get-LibreOffice` to work on PowerShell Core
* Changes `Get-LibreOffice` output and parameters to align with other functions
* Updates `Get-NotepadPlusPlus` to gracefully handle update server issues (CloudFlare DDOS challenges)
* Fixes version output in `Get-OpenJDK`
* Updates `Get-mRemoteNG` with handling issues when getting Updates
* Updates to Public function Pester tests
* Updates `Evergreen.json` with consistent property naming and corresponding functions

## 1910.62

* Updates `Get-MicrosoftSsms` to ensure that the URI property returns the correct SSMS download for the latest version

## 1910.53

* Adds `Get-WinMerge`

## 1910.50

* Updates `Get-VideoLanVlcPlayer` output to include ZIP and MSI links for VLC Player for Windows

## 1910.49

* Updates `Get-MicrosoftSsms` to URL (e.g. `https://go.microsoft.com/fwlink/?LinkId=761491`) to return actual URI

## 1910.48

* Updates `Get-VideoLanVlcPlayer` to return download mirrors for URI values

## 1910.47

* Adds `Get-Atom` and `Get-TeamViewer`

## 1910.39

* Update `Get-Zoom` to the same HTTP post as `https://zoom.us/support/download` to return the download URI. Returns download for Windows and VDI environments
* Build script changes

## 1910.28

* Adds `Get-mRemoteNG`
* Update version format to `YearMonth.Build` (hopefully we won't change this again)
* Automate versioning in the module to the new format
* Automate update of `appveyor.yml` as `YearMonth` changes
* Output variables in AppVeyor to `\tests\appveyor.md`

## 1910.18.26

* Adds `Get-OpenJDK`
* Changes version notation to: YearMonth.Day.Build

## 19.10.25

* Adds `Get-MicrosoftOffice`

## 19.10.24

* Fixes URIs for updates in `Get-AdobeAcrobatReaderDC`
* Adds additional Pester tests for Public functions to ensure generated URI values are valid

## 19.10.21

* Adds `Get-FoxitReader`

## 19.10.20

* Fixes output in `Get-GitForWindows`, `Get-MicrosoftSmss`

## 19.10.19

* Adds `Get-GitForWindows`, `Get-ShareX`

## 19.10.11

* Adds `Get-Java8`

## 19.10.9

* Adds `Get-BISF`
* Adds `ConvertTo-DateTime` private function to handle DateTime conversion on PowerShell Core / Windows PowerShell

## 19.10.2

* First version pushed to the PowerShell Gallery
* Initial functions are:

`Export-EvergreenResourceStrings`
`Get-AdobeAcrobatReaderDC`
`Get-CitrixAppLayeringFeed`
`Get-CitrixApplicationDeliveryManagementFeed`
`Get-CitrixEndpointManagementFeed`
`Get-CitrixGatewayFeed`
`Get-CitrixHypervisorFeed`
`Get-CitrixLicensingFeed`
`Get-CitrixReceiverFeed`
`Get-CitrixSdwanFeed`
`Get-CitrixVirtualAppsDesktopsFeed`
`Get-CitrixWorkspaceApp`
`Get-CitrixWorkspaceAppFeed`
`Get-CitrixXenServerTools`
`Get-ControlUpAgent`
`Get-FileZilla`
`Get-GoogleChrome`
`Get-Greenshot`
`Get-LibreOffice`
`Get-MicrosoftPowerShellCore`
`Get-MicrosoftSsms`
`Get-MicrosoftVisualStudioCode`
`Get-MozillaFirefox`
`Get-NotepadPlusPlus`
`Get-OracleVirtualBox`
`Get-PaintDotNet`
`Get-VideoLanVlcPlayer`
`Get-VMwareTools`
`Get-Zoom`

{% include links.html %}
