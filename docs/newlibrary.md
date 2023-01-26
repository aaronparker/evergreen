# Create a new Evergreen library

## About Evergreen Libraries

An Evergreen library is a directory that stores multiple versions of downloaded application installers, defined by `EvergreenLibrary.json` and gathered by `Get-EvergreenApp` and `Save-EvergreenApp`.

Evergreen typically returns only the most recent version of an application. An Evergreen library enables the download and storage of multiple versions of an application installer including the details for those versions. This functionality enables the installation of a specific version of an application as required.

## What makes an Evergreen library

An Evergreen library is a directory on a file system that contains `EvergreenLibrary.json` which defines the applications that will be downloaded and stored into the library. In the listing below, `EvergreenLibrary.json` lists the applications and how the output from `Get-EvergreenApp` should be filtered to store the specific application installer.

```json
{
    "Name": "EvergreenLibrary",
    "Applications": [
        {
            "Name": "Microsoft.NET",
            "EvergreenApp": "Microsoft.NET",
            "Filter": "$_.Architecture -eq \"x64\" -and $_.Installer -eq \"windowsdesktop\" -and $_.Channel -eq \"LTS\""
        },
        {
            "Name": "MicrosoftOneDrive",
            "EvergreenApp": "MicrosoftOneDrive",
            "Filter": "$_.Architecture -eq \"AMD64\" -and $_.Ring -eq \"Production\""
        },
        {
            "Name": "MicrosoftEdge",
            "EvergreenApp": "MicrosoftEdge",
            "Filter": "$_.Platform -eq \"Windows\" -and $_.Channel -eq \"Stable\" -and $_.Release -eq \"Enterprise\" -and $_.Architecture -eq \"x64\""
        },
        {
            "Name": "MicrosoftTeams",
            "EvergreenApp": "MicrosoftTeams",
            "Filter": "$_.Ring -eq \"General\" -and $_.Architecture -eq \"x64\" -and $_.Type -eq \"msi\""
        }
    ]
}
```

The filter can define any property from an application version object, so that you can download only the installer type that you require for the library. For example, you may have a library with production or release version of installers, and another library that hosts preview versions of application installers.

## Creating an Evergreen library

To create a new Evergreen library, use `New-EvergreenLibrary` and specifiy a valid local or UNC path:

```powershell
New-EvergreenLibrary -Path "\\server\EvergreenLibrary"
```

`New-EvergreenLibrary` will create the target directory and copy the default `EvergreenLibrary.json` into the path. The library will now be ready to download the 64-bit, release versions of:

* Microsoft.NET Desktop Runtime
* Microsoft OneDrive
* Microsoft Edge
* Microsoft Teams

If you would like to customise the library, open `EvergreenLibrary.json` in a JSON editor (e.g. Visual Studio Code) and add or remove applications as required.
