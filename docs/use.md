# Using Evergreen

`Get-EvergreenApp` is used to return application details by specifying an application with the `-Name` parameter.

For example, let's find the latest version of the Microsoft FSLogix Apps agent:

```powershell
Get-EvergreenApp -Name "MicrosoftFSLogixApps"
```

This will return output similar to the following that lists the version number and download URL for the application. This application output also includes the release date:

```powershell
Version : 2.9.7979.62170
Date    : 9/11/2021
Channel : Production
URI     : https://download.microsoft.com/download/3/f/7/3f755dbd-debe-46d4-811c-3e7c87bc4408/FSLogix_Apps_2.9.7979.62170.zip
```

All output properties are strings that can be acted on with other functions and cmdlets including filtering the output with `Where-Object`.

## Output

Each Evergreen application returns at least two properties in the object is sends to the pipeline:

* `Version` - a string property that is the version number of the application. If you need these in a version format, cast them with `[System.Version]`
* `URI` - a string property that is the download location for the latest version of the application. These will be publicly available locations that provide installers in typically Windows installer formats, e.g., `exe`, `msi`. Some downloads may be in other formats, such as `zip` that will need to be extracted before install

Several applications may include additional properties in their output, which will often require filtering, including:

* `Architecture` - the processor architecture of the installer
* `Type` - an application may return installer downloads in `exe`, `msi`, `zip`, format etc. In some instances, `Type` may return slightly different data
* `Ring`, `Channel`, and/or `Release` - some applications include different release rings or channels for enterprise use. The value of this property is often unique to that application
* `Language` - some application installers may support specific languages
* `Date` - in some cases, Evergreen can return the release date of the returned version

### Filter Output

Where an application returns more than one object to the pipeline, you will need to filter the output with `Where-Object` or `Sort-Object`. For example, `Get-EvergreenApp -Name MicrosoftTeams` returns both the 32-bit and 64-bit versions of the General and Preview release rings ot the Microsoft Teams installer. As most environments should be on 64-bit Windows these days, we can filter the 64-bit version of Teams with:

```powershell
Get-EvergreenApp -Name "MicrosoftTeams" | Where-Object { $_.Architecture -eq "x64" -and $_.Ring -eq "General" -and $_.Type -eq "msi" }
```

This will return details of the 64-bit Microsoft Teams installer that we can use in a script.

```powershell
Version      : 1.4.00.32771
Ring         : General
Architecture : x64
Type         : msi
URI          : https://statics.teams.cdn.office.net/production-windows-x64/1.4.00.32771/Teams_windows_x64.msi
```

### Use Output

With the filtered output we can download the latest version of Microsoft Teams before copying it to a target location or installing it directly to the current system. The following commands filters `Get-EvergreenApp -Name MicrosoftTeams` to get the latest version and download, then downloads the installer with `Save-EvergreenApp` and finally uses `msiexec` to install Teams in a VDI supported configuration:

```powershell
$Teams = Get-EvergreenApp -Name "MicrosoftTeams" | Where-Object { $_.Architecture -eq "x64" -and $_.Ring -eq "General" -and $_.Type -eq "msi" }
$TeamsInstaller = $Teams | Save-EvergreenApp -Path "C:\Temp\Teams"
& "$env:SystemRoot\System32\msiexec.exe" "/package $($TeamsInstaller.FullName) ALLUSER=1 ALLUSERS=1 /quiet"
```

## Parameters

### Name

The `-Name` parameter is used to specify the application name to return details for. This is a required parameter. The list of supported applications can be found with `Find-EvergreenApp`.

### Verbose

The `-Verbose` parameter can be useful for observing where the application details are obtained from (e.g. the application update URL) and for troubleshooting when the expected application details are not returned.

## Alias

`Get-EvergreenApp` has an alias of `gea` to simplify retrieving application details, for example:

```powershell
PS /Users/aaron> gea Slack

Version      : 4.14.0
Platform     : PerMachine
Architecture : x64
URI          : https://downloads.slack-edge.com/releases/windows/4.14.0/prod/x64/slack-standalone-4.14.0.0.msi
```
