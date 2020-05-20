# Tools

## New-WinGetManifest.ps1

`New-WinGetManifest.ps1` uses Evergreen to assist in generating a Windows Package Manager manifest that can the be submitted to the [Windows Package Manager manifest repository](https://github.com/microsoft/winget-pkgs).

### Example

Creates a Windows Package Manager manifest for the Microsoft FSLogix Apps agent and outputs the manifest in C:\Manifests.

```powershell
New-WinGetManifest -Package MicrosoftFSLogixApps -Path C:\Manifests
```
