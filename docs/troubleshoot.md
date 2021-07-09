# Troubleshooting

If you encounter an error when returning details for an existing application, re-run the `Get-EvergreenApp` with the `-Verbose` parameter. This will display additional details and should provide some indication as to where the request is failing.

In most cases, the issue will be caused by the vendor's source locations being temporarily unavailable (which should eventually resolve) and changing, which may require an update to the module.

In the example below, let's return details for `Zoom`:

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
