# Update an Evergreen Library

To update a library, use `Start-EvergreenLibraryUpdate` - this function will read the `EvergreenLibrary.json` file and use `Get-EvergreenApp` and `Save-EvergreenApp` to populate the library with the application installers and maintain a manifest of the application version information for later reference.

Here's an example - `EvergreenLibrary.json` contains the following entry for Microsoft Teams:

```json
{
    "Name": "MicrosoftTeams",
    "EvergreenApp": "MicrosoftTeams",
    "Filter": "$_.Ring -eq \"General\" -and $_.Architecture -eq \"x64\" -and $_.Type -eq \"msi\""
}
```

* `Name` - defines the application folder for the library. You may want to download both the 32-bit and 64-bit version of the Microsoft Teams installer
* `EvergreenApp` - defines the application name supported by Evergreen. The list of supported application names can be found with `Find-EvergreenApp`
* `Filter` - this is the filter typically used with `Get-EvergreenApp | Where-Object` to filter the application version information for a specific application installer

The Microsoft Teams installer will be downloaded in this example to the following folder structure: `\\server\EvergreenLibrary\MicrosoftTeams\General\1.5.00.17656\x64`. After the installers are successfully downloaded, the application version information is saved. For this example, `\\server\EvergreenLibrary\MicrosoftTeams\MicrosoftTeams.json` will be saved with the following details:

```json
{
  "Version": "1.5.00.17656",
  "URI": "https://statics.teams.cdn.office.net/production-windows-x64/1.5.00.17656/Teams_windows_x64.msi",
  "Type": "msi",
  "Ring": "General",
  "Path": "/Users/aaron/Temp/Evergreen/MicrosoftTeams/General/1.5.00.17656/x64/Teams_windows_x64.msi",
  "Architecture": "x64"
}
```

Each time a new version of Team installer is downloaded, `MicrosoftTeams.json` is updated with the new version for later use.

## How to update a library

`Start-EvergreenLibraryUpdate` has a single parameter - `-Path`, which should be the path to the Evergreen library:

```powershell
Start-EvergreenLibraryUpdate -Path "\\server\EvergreenLibrary"
```

If a path is specified that does not contain `EvergreenLibrary.json` and error will be thrown.

To download new application installers when a new version is detected, `Start-EvergreenLibraryUpdate` can be run via a scheduled task or other automation tools. This provides a simple method to update the library and make new application available for install or packaging.
