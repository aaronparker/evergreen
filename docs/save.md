# Download installers

Evergreen includes the function `Save-EvergreenApp` that simplifies downloading application installers that are returned from `Get-EvergreenApp`.

All applications will return at least a `Version` and `URI` property with many returning additional properties including `Architecture`, `Language`, `Type`, `Ring`, `Channel` and `Release`, dependent on the target application. Additionally, the installer file name is typically determined dynamically  with the `URI` property.

To retrieve and download an application installer, we need to use code similar to the following that the filters for the required download and determines the file name before using `Invoke-WebRequest` to download the file.

```powershell
$Teams = Get-EvergreenApp -Name MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" -and $_.Release -eq "Enterprise" }
$TeamsInstaller = Split-Path -Path $Teams.Uri -Leaf
Invoke-WebRequest -Uri $Teams.Uri -OutFile ".\$TeamsInstaller" -UseBasicParsing
```

This is a simple example, but an application with additional properties and output values is likely to require more complex code to download. For example, Microsoft OneDrive includes a few additional properties and several items in the returned object

```powershell
Version      : 89.0.774.68
Platform     : Windows
Channel      : Stable
Release      : Enterprise
Architecture : x64
Date         : 1/4/2021 7:29:00 pm
Hash         : 6E1856B2972688D109F550B0A62C264E9829FF1F392E3BE0FC308900AEFD3455
URI          : https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/a67b9c83-1671-45ab-982f-e02318eeffc9/MicrosoftEdgeEnterpriseX64.msi
```

`Save-EvergreenApp` accepts the output from each application and simplifies downloading the installers included in an application object by determining the target file name, and constructing a target directory path based on the properties in the application output.

```powershell
Get-EvergreenApp -Name MicrosoftOneDrive | Save-EvergreenApp -Path "C:\Apps\OneDrive"
```

`Save-EvergreenApp` will create a folder structure below the path provided (e.g. `C:\Apps\OneDrive`) built from the various properties in the application object passed to it. A folder structure, based on the available properties in the following list will be created in this order - `Channel`, `Release`, `Ring`, `Version`, `Language`, `Architecture`.

`Save-EvergreenApp` will return the path to each downloaded file that can be used passed to other functions in a script.

In the example using `MicrosoftOneDrive` above, `Save-EvergreenApp` returns output similar to this:

```powershell
Path
----
C:\Apps\OneDrive\Enterprise\20.169.0823.0008\OneDriveSetup.exe
C:\Apps\OneDrive\Production\21.030.0211.0002\OneDriveSetup.exe
C:\Apps\OneDrive\Production\21.052.0314.0001\OneDriveSetup.exe
C:\Apps\OneDrive\Insider\21.056.0318.0001\OneDriveSetup.exe
```

To download application installers into a single directory, the `-CustomPath` parameter can be used. Note that an application object can return multiple versions or channels of an application with the same installer name - when using `-CustomPath`, the first installer will be saved and subsequent installers with the same file name will be skipped.

!!! attention "Attention"
    `Save-EvergreenApp -CustomPath` will only download the first installer passed to the function where the object includes multiple installers with the same file name.

Therefore, when using `-CustomPath`, it would best to filter the output from `Get-EvergreenApp` before passing it to `Save-EvergreenApp`. For example:

```powershell
Get-EvergreenApp -Name MicrosoftOneDrive | `
    | Where-Object { $_.Ring -eq "Enterprise" -and $_.Architecture -eq "AMD64" -and $_.Type -eq "exe" } | `
    Save-EvergreenApp -Path "C:\Apps\OneDrive"
```

## Parameters

### InputObject

An object returned from `Get-EvergreenApp` with at least the `Version` and `URI` properties.

### Path

The parent directory under which a directory structure will be created and application installers saved into. Typically the target path used will be a path per application.

### CustomPath

The target directory into which the application installers will be directly saved into. Typically the target path used will be a path per application.

### Verbose

The `-Verbose` parameter can be useful for observing application downloads and save paths, including troubleshooting when the expected application details are not returned. When using the `-Verbose` parameter, `Invoke-WebRequest` will show download progress which significantly impacts download speed. To suppress download progress, add the `-NoProgress` switch parameter as well.

### -NoProgress

`Save-EvergreenApp` uses `Invoke-WebRequest` to download target application installers. Download progress is suppressed by default for faster downloads; however, when `-Verbose` is used, download progress will be displayed. Use `-NoProgress` with `-Verbose` to suppress download progress while also displaying verbose output.

### -Force

Forces this function to download the target application installers from the URI property even if they already exist in the target directory.

## Alias

`Save-EvergreenApp` has an alias of `sea` to simplify downloading applications, for example:

```powershell
PS /Users/aaron> gea Slack | sea -Path /Users/aaron/Temp/Slack
```
