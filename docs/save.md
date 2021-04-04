---
title: "Simplify saving applications"
keywords: evergreen
tags: [save]
sidebar: home_sidebar
permalink: save.html
summary: 
---
Evergreen includes the function `Save-EvergreenApp` that simplifies downloading application installers that are returned from `Get-EvergreenApp`.

All applications will return at least a `Version` and `URI` property with many returning additional properties including `Architecture`, `Language`, `Type`, `Ring`, `Channel` and `Release`, dependent on the target application. Additionally, the installer file name is typically determined dynamically  with the `URI` property.

So to retrieve and download an application installer, we need to use code similar to the following the filters for the specific download and determines the file name before using `Invoke-WebRequest` to download the file.

```powershell
$Teams = Get-EvergreenApp -Name MicrosoftTeams | Where-Object { $_.Architecture -eq "x64" -and $_.Ring -eq "General" }
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

Right now, the output path that `Save-EvergreenApp` builds cannot be customised.

## Parameters

### InputObject

The `-Name` parameter is used to specify the application name to return details for. This is a required parameter. The list of supported applications can be found with `Find-EvergreenApp`.

### Path

### Verbose

The `-Verbose` parameter can be useful for observing application downloads and save paths, including troubleshooting when the expected application details are not returned. When using the `-Verbose` parameter, `Invoke-WebRequest` will show download progress which significantly impacts download speed. To suppress download progress, add the `-NoProgress` switch parameter as well.

## Alias

`Save-EvergeeenApp` has an alias of `sea` to simplify downloading applications, for example:

```powershell
PS /Users/aaron> gea Slack | sea -Path /Users/aaron/Temp/Slack
```

{% include links.html %}
