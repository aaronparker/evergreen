# Retrieve endpoints used by Evergreen

The Evergreen API can return the endpoint URLs used by Evergreen to retrieve application version and download details, and endpoints URLs required to download application installers.

The list of endpoints can be imported into firewall or proxy server systems where an allowed list of endpoints is required before using Evergreen to download application installers. All endpoints are accessed on TCP 80 or 443.

## Usage

The API provides two lists of endpoints - URLs used by Evergreen to determine application versions and downloads, and URLs used to download application installers.

### Return a list of URLs used to determine application versions

The list of URLs used to determine application versions is used by the Evergreen PowerShell module. This information is already hosted in the Evergreen API and is not required if you are using the `/app/{appName}` API endpoint to find application version and installers. This list of URLs will update as supported applications in Evergreen are updated.

Here is an example using `Invoke-RestMethod` to return the list of URLs used by Evergreen to determine application versions:

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/versions"
```

### Return a list of URLs used to download application installers

This list of URLs is used when downloading application installers as determined by Evergreen. This list of URLs should remain largely static; however the list can change for some applications. For example, `Get-EvergreenApp -Name "VideoLanVlcPlayer` will return a list of download URLs based on the list of mirrors returned by VLC.

Here is an example using `Invoke-RestMethod` to return the list of URLs used by Evergreen when downloading application installers with `Save-EvergreenApp`:

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/downloads"
```

## Output

Output returns from both of these endpoints is in JSON format - the name of the application (a string) and the endpoints (an array) for that application are both returned. Here's sample output filtered for Microsoft Edge:

```json
{
  "Application": "MicrosoftEdge",
  "Endpoints": [
    "edgeupdates.microsoft.com",
    "www.microsoft.com"
  ]
}
```

If you are using PowerShell, use `Invoke-RestMethod` to return an object of applications and endpoints:

```powershell
$Endpoints = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/versions"
$Endpoints | Where-Object { $_.Name -eq "MicrosoftEdge" }

Application   Endpoints
-----------   ---------
MicrosoftEdge {edgeupdates.microsoft.com, www.microsoft.com}
```
