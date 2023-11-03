# Troubleshooting

## Wait and Try Again

The most common issues we see are transient - because Evergreen sources updates at the time you run the `Get-EvergreenApp`, the results can be affected by anything between you and the application vendor data source. An issue could be caused by network or DNS issues, of often by a vendor making changes on their end.

If you experience an issue, wait an hour and try again.

## Function Errors

If you encounter an error when returning details for an existing application, re-run the `Get-EvergreenApp` with the `-Verbose` parameter. This will display additional details and should provide some indication as to where the request is failing.

In most cases, the issue will be caused by the vendor's source locations being temporarily unavailable (which should eventually resolve) or changing, which may require an update to the module.

### Example - MicrosoftWvdInfraAgent

In this example, we can see that calling `MicrosoftWvdInfraAgent` results in a HTTP 503 error. Running the command later in the day, resulted in a successful request. Here we've encountered an issue with the vendor's source which was resolved without further action.

```powershell
Get-EvergreenApp -Name "MicrosoftWvdInfraAgent"

Invoke-EvergreenWebRequest : Invoke-EvergreenWebRequest: The remote server returned an error: (503) Server Unavailable..
At C:\projects\evergreen\Evergreen\Apps\Get-MicrosoftWvdInfraAgent.ps1:25 char:16
+     $Content = Invoke-EvergreenWebRequest @params
+                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
    + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Invoke-EvergreenWebRequest
```

### Example - MicrosoftWvdMultimediaRedirection

In this example, we again have a HTTP 503 error, so the source location is probably unavailable.

```powershell
Get-EvergreenApp -Name "MicrosoftWvdMultimediaRedirection"

WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4QWrF.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
Write-Error: /Users/aaron/projects/evergreen/Evergreen/Apps/Get-MicrosoftWvdMultimediaRedirection.ps1:25
Line |
  25 |      $Content = Invoke-EvergreenWebRequest @params
     |                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Invoke-EvergreenWebRequest: Response status code does not indicate success: 503 (Service Unavailable)..

WARNING: Get-MicrosoftWvdMultimediaRedirection: Failed to return a header from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4QWrF.
Exception: /Users/aaron/projects/evergreen/Evergreen/Public/Get-EvergreenApp.ps1:80
Line |
  80 |                  throw "Failed to capture output from: Get-$Name."
     |                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Failed to capture output from: Get-MicrosoftWvdMultimediaRedirection.
```

If we run the same command with the `-Verbose` parameter, some more detail will be provided.

```powershell
Get-EvergreenApp -Name "MicrosoftWvdMultimediaRedirection" -Verbose

VERBOSE: Function path: /Users/aaron/projects/evergreen/Evergreen/Apps/Get-MicrosoftWvdMultimediaRedirection.ps1
VERBOSE: Function exists: /Users/aaron/projects/evergreen/Evergreen/Apps/Get-MicrosoftWvdMultimediaRedirection.ps1.
VERBOSE: Dot sourcing: /Users/aaron/projects/evergreen/Evergreen/Apps/Get-MicrosoftWvdMultimediaRedirection.ps1.
VERBOSE: Get-FunctionResource: read application resource strings from [/Users/aaron/projects/evergreen/Evergreen/Manifests/MicrosoftWvdMultimediaRedirection.json]
VERBOSE: Calling: Get-MicrosoftWvdMultimediaRedirection.
VERBOSE: Invoke-EvergreenWebRequest: Invoke-WebRequest parameter: [Method: Head].
VERBOSE: Invoke-EvergreenWebRequest: Invoke-WebRequest parameter: [UserAgent: Mozilla/5.0 (Macintosh; Darwin 21.5.0 Darwin Kernel Version 21.5.0: Tue Apr 26 21:08:29 PDT 2022; root:xnu-8020.121.3~4/RELEASE_ARM64_T8101; en-AU) AppleWebKit/534.6 (KHTML, like Gecko) Chrome/7.0.500.0 Safari/534.6].
VERBOSE: Invoke-EvergreenWebRequest: Invoke-WebRequest parameter: [UseBasicParsing: True].
VERBOSE: Invoke-EvergreenWebRequest: Invoke-WebRequest parameter: [Uri: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4QWrF].
VERBOSE: HEAD with 0-byte payload
VERBOSE: received 175-byte response of content type text/html
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4QWrF.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
Write-Error: /Users/aaron/projects/evergreen/Evergreen/Apps/Get-MicrosoftWvdMultimediaRedirection.ps1:25
Line |
  25 |      $Content = Invoke-EvergreenWebRequest @params
     |                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Invoke-EvergreenWebRequest: Response status code does not indicate success: 503 (Service Unavailable)..

WARNING: Get-MicrosoftWvdMultimediaRedirection: Failed to return a header from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4QWrF.
Exception: /Users/aaron/projects/evergreen/Evergreen/Public/Get-EvergreenApp.ps1:80
Line |
  80 |                  throw "Failed to capture output from: Get-$Name."
     |                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Failed to capture output from: Get-MicrosoftWvdMultimediaRedirection.
```

### Example - Zoom

In the example below, let's return details for `Zoom` with the `-Verbose` parameter which will provide an idea of what Evergreen is doing as it retrieves details for Zoom:

```powershell
Get-EvergreenApp -Name "Zoom" -Verbose

VERBOSE: Get-EvergreenApp: Function exists: /Users/aaron/Projects/evergreen/Evergreen/Apps/Get-Zoom.ps1.
VERBOSE: Get-EvergreenApp: Dot sourcing: /Users/aaron/Projects/evergreen/Evergreen/Apps/Get-Zoom.ps1.
VERBOSE: Get-EvergreenApp: Calling: Get-Zoom.
VERBOSE: Get-FunctionResource: read application resource strings from [/Users/aaron/Projects/evergreen/Evergreen/Manifests/Zoom.json]
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/download/vdi/ZoomCitrixHDXMediaPlugin.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/vdi/ZoomCitrixHDXMediaPlugin.msi?_x_zm_rtaid=1ntgQ-l3TsyzTXmWzDs59w.1625872867055.20bd6639bacc03053f5e85d49d21fc77&_x_zm_rhtaid=731].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/client/latest/ZoomInstaller.exe.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/5.7.1.543/ZoomInstaller.exe].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/client/latest/ZoomOutlookPluginSetup.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/5.7.0.64/ZoomOutlookPluginSetup.msi].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/client/latest/ZoomNotesPluginSetup.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/5.7.0.65/ZoomNotesPluginSetup.msi].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/client/latest/ZoomInstallerFull.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/5.7.1.543/ZoomInstallerFull.msi].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/client/latest/ZoomRooms.exe.
WARNING: Resolve-SystemNetWebRequest: Error at URI: https://zoom.us/client/latest/ZoomRooms.exe.
WARNING: Resolve-SystemNetWebRequest: Response:  -
WARNING: Resolve-SystemNetWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
VERBOSE: Get-Zoom: Setting fallback URL to: https://stealthpuppy.com/evergreen/issues/.
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/client/latest/ZoomLyncPluginSetup.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/5.2.44882.0827/ZoomLyncPluginSetup.msi].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/download/vdi/ZoomVmwareMediaPlugin.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/vdi/ZoomVmwareMediaPlugin.msi?_x_zm_rtaid=kow6DBRDQhO8sS9-JyHTDQ.1625872876745.f65b9ac6613cb7a22686fc40291be0bf&_x_zm_rhtaid=705].
VERBOSE: Resolve-SystemNetWebRequest: Attempting to resolve: https://zoom.us/download/vdi/ZoomInstallerVDI.msi.
VERBOSE: Resolve-SystemNetWebRequest: Response: [OK].
VERBOSE: Resolve-SystemNetWebRequest: Resolved to: [https://cdn.zoom.us/prod/vdi/ZoomInstallerVDI.msi?_x_zm_rtaid=EiXK_i85Qnyxl0PnXE6ITg.1625872878653.8a666f93edfe18920e810d72dadd4246&_x_zm_rhtaid=751].
VERBOSE: Get-EvergreenApp: Output result from: /Users/aaron/Projects/evergreen/Evergreen/Apps/Get-Zoom.ps1.
```

In this request we can see there's an issue at `https://zoom.us/client/latest/ZoomRooms.exe`. Validating this URL in the browser or with `Invoke-WebRequest` we can see the the source is unavailable. The vendor may have temporarily moved the source, thus Evergreen will work once the source is available again. If the vendor has updated the source location permanently, Evergreen will require updates to use the new source locations.

## Output Errors

### Suppressing Errors and Warning

Some functions may output errors and warnings, but still return application version information. In the example below, `MicrosoftWvdRemoteDesktop` returns data, but outputs several warnings:

```powershell
Get-EvergreenApp -Name "MicrosoftWvdRemoteDesktop"

WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51od9.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
WARNING: Get-MicrosoftWvdRemoteDesktop: Unable to retrieve headers from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51od9.
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy7.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
WARNING: Get-MicrosoftWvdRemoteDesktop: Unable to retrieve headers from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy7.
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51od9.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
WARNING: Get-MicrosoftWvdRemoteDesktop: Unable to retrieve headers from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51od9.
WARNING: Invoke-EvergreenWebRequest: Error at URI: https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy7.
WARNING: Invoke-EvergreenWebRequest: Error encountered: Response status code does not indicate success: 503 (Service Unavailable)..
WARNING: Invoke-EvergreenWebRequest: For troubleshooting steps see: https://stealthpuppy.com/evergreen/troubleshoot/.
WARNING: Get-MicrosoftWvdRemoteDesktop: Unable to retrieve headers from https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy7.
```

These warnings can be suppressed with the `-WarningAction` parameter:

```powershell
Get-EvergreenApp -Name "MicrosoftWvdRemoteDesktop" -ErrorAction "SilentlyContinue" -WarningAction "SilentlyContinue"
```

### Unexpected Output

Where the output from a function is producing output that is clearly incorrect, you should [log an issue](https://github.com/aaronparker/evergreen/issues).

What may be more common is filtering the output incorrectly and not receiving the expected result. Here's an example output from `MicrosoftWvdRemoteDesktop` which has several releases with multiple properties. Viewing the output without any filtering will show all releases and all properties:

```powershell
Get-EvergreenApp -Name "MicrosoftWvdRemoteDesktop" | Format-Table

Version    Architecture Channel Date      Filename                           URI
-------    ------------ ------- ----      --------                           ---
1.2.3401.0 ARM64        Insider Unknown   RemoteDesktop_1.2.3401.0_ARM64.msi https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51od9
1.2.3401.0 x64          Insider 19/7/2022 RemoteDesktop_1.2.3401.0_x64.msi   https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy5
1.2.3401.0 x86          Insider Unknown   RemoteDesktop_1.2.3401.0_x86.msi   https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy7
1.2.3401.0 ARM64        Dogfood Unknown   RemoteDesktop_1.2.3401.0_ARM64.msi https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51od9
1.2.3401.0 x64          Dogfood 19/7/2022 RemoteDesktop_1.2.3401.0_x64.msi   https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy5
1.2.3401.0 x86          Dogfood Unknown   RemoteDesktop_1.2.3401.0_x86.msi   https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE51gy7
1.2.3317.0 ARM64        Public  13/7/2022 RemoteDesktop_1.2.3317.0_ARM64.msi https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE50W7e
1.2.3317.0 x64          Public  13/7/2022 RemoteDesktop_1.2.3317.0_x64.msi   https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE518ld
1.2.3317.0 x86          Public  13/7/2022 RemoteDesktop_1.2.3317.0_x86.msi   https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE50W7f
```

To return a single release, we can filter the output with `Where-Object`, which does require syntax to be correct and use the expected value for each property in the filter:

```powershell
Get-EvergreenApp -Name "MicrosoftWvdRemoteDesktop" | Where-Object { $_.Architecture -eq "x64" -and $_.Channel -eq "Public" }

Version      : 1.2.3317.0
Architecture : x64
Channel      : Public
Date         : 13/7/2022
Filename     : RemoteDesktop_1.2.3317.0_x64.msi
URI          : https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE518ld
```
