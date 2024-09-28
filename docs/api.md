# How to use the Evergreen API

!!! warning

    **The Evergreen API is provided free of charge - please don't abuse it**. The API is currently provided by the free tier of Cloudflare Workers which provides up to 100,000 total requests per day. The API is intended for development purposes only and not for use with distributed endpoints.
    
    If you encounter issues or would prefer to ensure data is only sourced from the application vendor, use `Get-EvergreenApp`.

Evergreen's difference to other methods of finding and installing applications, is that Evergreen queries only official vendor sources when you use `Get-EvergreenApp`. This ensures that the information returned can be trusted because it comes from the vendor and is not crowd sourced.

Evergreen supports [an API](https://evergreen-api.stealthpuppy.com/) that returns the same application version information as `Get-EvergreenApp`. The API supports the same applications as the Evergreen module because data is sourced via the module. The API runs on Cloudflare Workers with data that is updated every 8 hours.

Full documentation for the API is available here: [evergreen-api](https://app.swaggerhub.com/apis/stealthpuppy/evergreen-api/1.0.0); however, if you're familiar with `Get-EvergreenApp` in the Evergreen module, the API should be easy to use.

Data that is returned by the Evergreen API can be viewed at the [Evergreen App Tracker](https://stealthpuppy.com/apptracker/).

## Usage

In its current version, the API has only two endpoints that return data in JSON format - `/apps`, `/app/{appName}`. In PowerShell, the API can be queried with `Invoke-RestMethod`.

Return the list of supported applications from `/apps` - this is the equivalent of running `Find-EvergreenApp`:

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/apps"
```

Details for a specific application are returned from the `/app/{appName}` endpoint along with the name of the supported application.

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/app/MicrosoftEdge"
```

Data returned from the API can be  filtered and sent to `Save-EvergreenApp` to download binaries:

```powershell
$Edge = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/app/MicrosoftEdge"
$Edge | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise" } | Save-EvergreenApp -Path "C:\Apps"
```

If an unknown application is passed to the `/app` endpoint, an error is returned:

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/app/UnsupportedApp"
Invoke-RestMethod: {message: "Application not found. List all apps for valid application names. Application names are case sensitive.}
```

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
