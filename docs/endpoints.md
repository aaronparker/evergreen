# Retrieve endpoints used by Evergreen

The Evergreen API can return the endpoint URLs used by Evergreen to retrieve application version and download details, and endpoints URLs required to download application installers.

The list of endpoints can be imported into firewall or proxy server systems where an allowed list of endpoints is required before using Evergreen to download application installers.

## Usage

The API provides two lists of endpoints - URLs used by Evergreen to determine application versions and downloads, and URLs used to download application installers.

### Return a list of URLs used to determine updates

The list of URLs used to determine updates is used by the Evergreen PowerShell module. This information is already hosted in the Evergreen API and is not required if you are using the `/app/{appName}` API endpoint to find application version and installers. This list of URLs will update as supported applications in Evergreen are updated.

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/updates"
```

### Return a list of URLs used to download application installers

This list of URLs is used when downloading application installers as determined by Evergreen. This list of URLs should remain largely static; however the list can change for some applications. For example, `Get-EvergrenApp -Name "VideoLanVlcPlayer` will return a list of download URLs based on the list of mirrors returned by VLC.

```powershell
PS C:\> Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/downloads"
```
