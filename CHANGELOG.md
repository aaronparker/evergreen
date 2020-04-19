# Change Log

## VERSION

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

* First verison pushed to the PowerShell Gallery
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
