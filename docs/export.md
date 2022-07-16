# Export version information

`Export-EvergreenApp` can be used to export application version information, returned from `Get-EvergreenApp`, to JSON and store the information in a file. This can be useful for tracking details of application versions in a software library.

The following example shows how to gather application version information for Microsoft OneDrive, save the OneDrive installers to a target directory and store the application version information in a JSON file.

```powershell
$OneDrive = Get-EvergreenApp -Name "MicrosoftOneDrive"
Save-EvergreenApp -InputObject $OneDrive -Path "C:\Evergreen\OneDrive"
Export-EvergreenApp -InputObject $OneDrive -Path "C:\Evergreen\OneDrive\MicrosoftOneDrive.json"
```

If an existing JSON file is specified on the `-Path` parameter of`Export-EvergreenApp`, the new application version information will be added to the file, with duplicates removed. The file will include JSON data similar to the following:

```json
[
  {
    "Version": "22.077.0410.0007",
    "URI": "https://oneclient.sfx.ms/Win/Enterprise/22.077.0410.0007/OneDriveSetup.exe",
    "Type": "exe",
    "Sha256": "jjiooBnk6w0tEt20O1IWzT63jvuFUxpZgJDoJdpkDgg=",
    "Ring": "Enterprise",
    "Architecture": "x86"
  },
  {
    "Version": "22.077.0410.0007",
    "URI": "https://oneclient.sfx.ms/Win/Enterprise/22.077.0410.0007/amd64/OneDriveSetup.exe",
    "Type": "exe",
    "Sha256": "JjoeTY78Krp49KXJEyjtE1O9WSuFmFoNKECtVwKGDW8=",
    "Ring": "Enterprise",
    "Architecture": "AMD64"
  },
  {
    "Version": "22.131.0619.0001",
    "URI": "https://oneclient.sfx.ms/Win/Prod/22.131.0619.0001/OneDriveSetup.exe",
    "Type": "exe",
    "Sha256": "ObZEdqfd8gn9RhzR4SkuVS+Xu4R0vye5OnAaUgRl9E4=",
    "Ring": "Production",
    "Architecture": "x86"
  }
]
```

!!! note

    `Export-EvergreenApp` does not truncate date in the exported file. You will have to manage data with a seperate process as the file grows.

The JSON file can be read back into an object with `ConvertFrom-Json`:

```powershell
Get-Content -Path "C:\Evergreen\OneDrive\MicrosoftOneDrive.json" | ConvertFrom-Json
```
