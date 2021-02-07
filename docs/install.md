---
title: "Installing Evergreen"
keywords: evergreen
tags: [install, update]
sidebar: home_sidebar
permalink: install.html
summary: How to install the Evergreen PowerShell module
---
## Install from the PowerShell Gallery

The Evergreen module is published to the PowerShell Gallery and can be found here: [Evergreen](https://www.powershellgallery.com/packages/Evergreen/). The module can be installed from the gallery with:

```powershell
Install-Module -Name Evergreen
Import-Module -Name Evergreen
```

### Updating the Module

If you have installed a previous version of the module from the gallery, you can install the latest update with `Update-Module` and the `-Force` parameter:

```powershell
Update-Module -Name Evergreen -Force
```

### Advanced Installation

In scripted installations (e.g. operating system deployment), you may wish to ensure that the PowerShell Gallery is first trusted before attempting to install the module:

```powershell
If (Get-PSRepository | Where-Object { $_.Name -eq "PSGallery" -and $_.InstallationPolicy -ne "Trusted" }) {
    Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.208 -Force
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}
```

Then we can install or update Evergreen based on whether the module is already installed or out of date:

```powershell
$Installed = Get-Module -Name "Evergreen" -ListAvailable | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
    Select-Object -First 1
$Published = Find-Module -Name "Evergreen"
If ($Null -eq $Installed) {
    Install-Module -Name "Evergreen"
}
ElseIf ([System.Version]$Published.Version -gt [System.Version]$Installed.Version) {
    Update-Module -Name "Evergreen"
}
```

## Manual Installation from the Repository

The module can be downloaded from the [GitHub source repository](https://github.com/aaronparker/Evergreen) which includes the module in the `Evergreen` folder. The folder needs to be copied into one of your PowerShell Module Paths. To see the full list of available PowerShell Module paths, use `$env:PSModulePath.split(';')` in a PowerShell console.

Common PowerShell module paths include:

* Current User: `%USERPROFILE%\Documents\WindowsPowerShell\Modules\`
* All Users: `%ProgramFiles%\WindowsPowerShell\Modules\`
* OneDrive: `$env:OneDrive\Documents\WindowsPowerShell\Modules\`

To install from the repository

1. Download the `master branch` to your workstation
2. Copy the contents of the Evergreen folder onto your workstation into the desired PowerShell Module path
3. Open a Powershell console with the Run as Administrator option
4. Run `Set-ExecutionPolicy` using the parameter `RemoteSigned` or `Bypass`
5. Unblock the files with `Get-ChildItem -Path <path to module> -Recurse | Unblock-File`

Once installation is complete, you can validate that the module exists by running `Get-Module -ListAvailable Evergreen`. To use the module, load it with:

```powershell
Import-Module Evergreen
```

{% include links.html %}
