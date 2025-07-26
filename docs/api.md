# How to use the Evergreen API

!!! warning

    **The Evergreen API is provided free of charge - please don't abuse it**. The API is currently provided by the free tier of Cloudflare Workers which provides up to 100,000 total requests per day. The API is intended for development purposes only and not for use with distributed endpoints.
    
    If you encounter issues or would prefer to ensure data is only sourced from the application vendor, use `Get-EvergreenApp`.

Evergreen's difference to other methods of finding and installing applications, is that Evergreen queries only official vendor sources when you use `Get-EvergreenApp`. This ensures that the information returned can be trusted because it comes from the vendor and is not crowd sourced.

Evergreen supports [an API](https://evergreen-api.stealthpuppy.com/) that returns the same application version information as `Get-EvergreenApp`. The API supports the same applications as the Evergreen module because data is sourced via the module. The API runs on Cloudflare Workers with data that is updated every 8 hours.

Full documentation for the API is available here: [evergreen-api](https://app.swaggerhub.com/apis/stealthpuppy/evergreen-api/); however, if you're familiar with `Get-EvergreenApp` in the Evergreen module, the API should be easy to use.

The data that is returned by the Evergreen API is maintained and updated via the [Evergreen App Tracker](https://stealthpuppy.com/apptracker/). Use the App Tracker to review the API data.

## Get-EvergreenAppFromApi

Evergreen includes the `Get-EvergreenAppFromApi` function that is used in much the same way as `Get-EvergreenApp`. This function is simpler than using `Invoke-RestMethod`, and it automatically filters for available applications. For example, to query the API for application data for Microsoft Edge, use:

```powershell
PS C:\> Get-EvergreenAppFromApi -Name "MicrosoftEdge"

Version      : 89.0.774.76
Platform     : Windows
Channel      : Stable
Release      : Enterprise
Architecture : x64
Date         : 12/4/2021
Hash         : 9E7A29B4BE6E1CD707F80B4B79008F19D2D5DD5C774D317A493EC6DE5BE0B7D7
URI          : https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4d12f620-174c-4259-85e6-8a80ea45ff10/MicrosoftEdgeEnterpriseX64.msi
```

This returns the current version and download URLs for Microsoft Edge using the official Microsoft Edge update API at [https://edgeupdates.microsoft.com/api/products](https://edgeupdates.microsoft.com/api/products).

Just as with `Get-EvergreenApp`, the output can be filtered for the specific application installer with `Where-Object`. The example below returns the current version and download URL for the Stable channel of the 64-bit Enterprise ring of Microsoft Edge.

```powershell
Get-EvergreenAppFromApi -Name "MicrosoftEdge" | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" }
```

## Get-EvergreenEndpointFromApi

Evergreen includes the `Get-EvergreenEndpointFromApi` function that returns the full list of vendor endpoints used by Evergreen, enabling the output to be used for auditing or firewall rules etc.

```powershell
Get-EvergreenEndpointFromApi

Application                          Endpoints                                                                                                      Ports
-----------                          ---------                                                                                                      -----
1Password                            {1password.com, app-updates.agilebits.com, downloads.1password.com, cdn.agilebits.com}                         {443}
1Password7                           {1password.com, c.1password.com}                                                                               {443}
1PasswordCLI                         {app-updates.agilebits.com, cache.agilebits.com, developer.1password.com}                                      {443}
7Zip                                 {api.github.com, www.7-zip.org, github.com}                                                                    {443}
7ZipZS                               {api.github.com, mcmilk.de, github.com}                                                                        {443}
AdobeAcrobat                         {ardownload2.adobe.com, armmf.adobe.com, helpx.adobe.com}                                                      {443}
AdobeAcrobatDC                       {ardownload2.adobe.com, rdc.adobe.io, www.adobe.com}                                                           {443}
AdobeAcrobatProStdDC                 {helpx.adobe.com, rdc.adobe.io, trials.adobe.com}                                                              {443}
AdobeAcrobatReaderDC                 {acrobat.adobe.com, rdc.adobe.io, ardownload2.adobe.com}                                                       {443}
```

## Custom Usage

The API has only two endpoints that return data in JSON format:

* `/apps` - returns the list of supported applications
* `/app/{appName}` - returns data for a specified application
* `/endpoints/versions` - returns the list of vendor endpoints used by Evergreen to query details for an application (i.e. used by `Get-EvergrenApp`)
* `/endpoints/downloads` - returns the list of vendor endpoints used for downloads  (i.e. used by `Save-EvergrenApp`)

!!! note

    The API requires a custom user agent. Default user agents for PowerShell, curl, wget, browers etc. are blocked to prevent random requests and abuse of the API. Please specify a user agent that identifies your usage or organisation to assist with troubleshooting.

Return the list of supported applications from `/apps` - this is the equivalent of running `Find-EvergreenApp`:

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/apps" -UserAgent "My custom UA"
```

Details for a specific application are returned from the `/app/{appName}` endpoint along with the name of the supported application.

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/app/MicrosoftEdge" -UserAgent "My custom UA"
```

Data returned from the API can be  filtered and sent to `Save-EvergreenApp` to download binaries:

```powershell
$Edge = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/app/MicrosoftEdge"
$Edge | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" } | Save-EvergreenApp -Path "C:\Apps"
```

If an unknown application is passed to the `/app` endpoint, an error is returned:

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/app/UnsupportedApp" -UserAgent "My custom UA"
Invoke-RestMethod: {message: "Application not found. List all apps for valid application names. Application names are case sensitive.}
```
