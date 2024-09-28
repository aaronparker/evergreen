# Retrieve endpoints used by Evergreen

The Evergreen API can return the endpoint URLs used by Evergreen to retrieve application version and download details, and endpoints URLs required to download application installers.

The list of endpoints can be imported into firewall or proxy server systems where an allowed list of endpoints is required before using Evergreen to download application installers. All endpoints are accessed on TCP 80 or 443.

## API Usage

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

### Output

Output returns from both of these endpoints is in JSON format - the name of the application (a string) and the endpoints (an array) for that application are both returned. Here's sample output filtered for Microsoft Edge:

```json
{
    "Application": "MicrosoftEdge",
    "Endpoints": [
        "msedge.sf.dl.delivery.mp.microsoft.com"
    ],
    "Ports": [
        "443"
    ]
}
```

If you are using PowerShell, use `Invoke-RestMethod` to return an object of applications and endpoints:

```powershell
$Endpoints = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/versions"
$Endpoints | Where-Object { $_.Application -eq "MicrosoftEdge" }

Application   Endpoints                                      Ports
-----------   ---------                                      -----
MicrosoftEdge {edgeupdates.microsoft.com, www.microsoft.com} {443}
```

## Using Get-EvergreenEndpointFromApi

`Get-EvergreenEndpointFromApi` can be used to simplify usage of the API, by returning all endpoints used by Evergreen in a single object. Running `Get-EvergreenEndpointFromApi` with no parameters, will return a complete list of endpoints and ports used for all applications.

```powershell
PS C:\> Get-EvergreenEndpointFromApi

Application          Endpoints                                                                              Ports
-----------          ---------                                                                              -----
1Password            {1password.com, app-updates.agilebits.com, downloads.1password.com, cdn.agilebits.com} {443}
1Password7           {1password.com, c.1password.com}                                                       {443}
1PasswordCLI         {app-updates.agilebits.com, cache.agilebits.com, developer.1password.com}              {443}
7zip                 {nchc.dl.sourceforge.net, sourceforge.net, www.7-zip.org, versaweb.dl.sourceforge.net} {443}
7ZipZS               {api.github.com, mcmilk.de, github.com}                                                {443}
AdobeAcrobat         {ardownload2.adobe.com, armmf.adobe.com, helpx.adobe.com}                              {443}
AdobeAcrobatDC       {ardownload2.adobe.com, rdc.adobe.io, www.adobe.com}                                   {443}
AdobeAcrobatProStdDC {helpx.adobe.com, rdc.adobe.io, trials.adobe.com}                                      {443}
AdobeAcrobatReaderDC {acrobat.adobe.com, rdc.adobe.io, ardownload2.adobe.com}                               {443}
AdobeBrackets        {brackets.io, api.github.com, github.com}                                              {80, 443}
```

`Get-EvergreenEndpointFromApi` can return endpoints for a single application or an array of with the `-Name` parameter. In the example below `Get-EvergreenEndpointFromApi` is used to return the endpoints and ports for the Microsoft Teams and Microsoft Edge endpoints.

```powershell
PS C:\> Get-EvergreenEndpointFromApi -Name "MicrosoftTeams", "MicrosoftEdge"

Application    Endpoints                                                                              Ports
-----------    ---------                                                                              -----
MicrosoftEdge  {edgeupdates.microsoft.com, www.microsoft.com, msedge.sf.dl.delivery.mp.microsoft.com} {443}
MicrosoftTeams {config.teams.microsoft.com, www.microsoft.com, statics.teams.cdn.office.net}          {443}
```

### Return a simple list of all endpoints

The output of `Get-EvergreenEndpointFromApi` can be filtered to create a simple list of all unique endpoint URLs. The command below will generate an array of URLs that can then be used for an allow list of all endpoints required by Evergreen.

```powershell
PS C:\> Get-EvergreenEndpointFromApi | Select-Object -ExpandProperty "Endpoints" -Unique
```

### Convert output to CSV

The code below can be used to convert the output from `Get-EvergreenEndpointFromApi` to a file in CSV format. The file will include the application name, endpoints URLs in a comma separated list, and ports in a comma separated list.

```powershell
$Path = "./Endpoints.csv"
Get-EvergreenEndpointFromApi | ForEach-Object {
    [PSCustomObject]@{
        Application = $_.Application
        Endpoints   = $_.Endpoints -join ","
        Ports       = $_.Ports -join ","
    }
} | Export-Csv -Path $Path -NoTypeInformation -Encoding "Utf8" -Append
```
