# Test Installers

Evergreen includes the function `Test-EvergreenApp` that can test whether the application installer URLs returned from `Get-EvergreenApp` exist at the URL specified. `Test-EvergreenApp` will enable you to quickly validate whether the application installer exists.

In the following example, we can test whether the URLs returned by `MicrosoftOneDrive` exist:

```powershell
Get-EvergreenApp -Name "MicrosoftOneDrive" | Where-Object { $_.Type -eq "exe" } | Test-EvergreenApp

URI                                                                            Result
---                                                                            ------
https://oneclient.sfx.ms/Win/MsitFast/22.082.0417.0001/amd64/OneDriveSetup.exe   True
https://oneclient.sfx.ms/Win/MsitFast/22.082.0417.0001/OneDriveSetup.exe         True
https://oneclient.sfx.ms/Win/Insiders/22.077.0410.0007/OneDriveSetup.exe         True
https://oneclient.sfx.ms/Win/Insiders/22.077.0410.0007/amd64/OneDriveSetup.exe   True
https://oneclient.sfx.ms/Win/MsitSlow/22.077.0410.0006/OneDriveSetup.exe         True
https://oneclient.sfx.ms/Win/MsitSlow/22.077.0410.0006/amd64/OneDriveSetup.exe   True
https://oneclient.sfx.ms/Win/Insiders/22.070.0403.0004/amd64/OneDriveSetup.exe   True
https://oneclient.sfx.ms/Win/Insiders/22.070.0403.0004/OneDriveSetup.exe         True
https://oneclient.sfx.ms/Win/Prod/22.065.0412.0004/amd64/OneDriveSetup.exe       True
https://oneclient.sfx.ms/Win/Prod/22.065.0412.0004/OneDriveSetup.exe             True
https://oneclient.sfx.ms/Win/Enterprise/21.230.1107.0004/OneDriveSetup.exe       True
https://oneclient.sfx.ms/Win/Enterprise/21.230.1107.0004/amd64/OneDriveSetup.…   True
```

## Parameters

### InputObject

An object returned from `Get-EvergreenApp` with at least the `Version` and `URI` properties.

### Verbose

The `-Verbose` parameter can be useful for observing application downloads and save paths, including troubleshooting when the expected application details are not returned. When using the `-Verbose` parameter, `Invoke-WebRequest` will show download progress which significantly impacts download speed. To suppress download progress, add the `-NoProgress` switch parameter as well.

## Alias

`Test-EvergreenApp` has an alias of `tea` to simplify testing applications, for example:

```powershell
PS /Users/aaron> gea MicrosoftTeams | tea
```
