# Install an application from a library

Once an Evergreen library is populated with application downloads, it can be queried for a specific application for the available versions of that application with `Get-EvergreenAppFromLibrary`. Details of the Evergreen library must be passed to `Get-EvergreenAppFromLibrary` from `Get-EvergreenLibrary`.

The application details that are returned will include the version and path to the installer binaries for installing the target application. Application details are returned in descending order of version, thus the latest available version can be used or the details filtered for a specific version.

## Examples

In this example, details of the target library at `\\server\EvergreenLibrary` are returned with `Get-EvergreenLibrary` and placed into a variable `$Library`. `Get-EvergreenAppFromLibrary` is then used to search for Microsoft Visual Studio Code in the library.

```powershell
PS C:\> $Library = Get-EvergreenLibrary -Path "\\server\EvergreenLibrary"
PS C:\> Get-EvergreenAppFromLibrary -Inventory $Library -Name "MicrosoftVisualStudioCode"

Version      : 1.74.3
URI          : https://az764295.vo.msecnd.net/stable/97dec172d3256f8ca4bfb2143f3f76b503ca0534/VSCodeSetup-x64-1.74.3.exe
Sha256       : cea32aa015116f8346e054c59497908f6da6059361c1b33d5b68059031f2dc97
Platform     : win32-x64
Path         : \\server\EvergreenLibrary\MicrosoftVisualStudioCode\Stable\1.74.3\x64\VSCodeSetup-x64-1.74.3.exe
Channel      : Stable
Architecture : x64

Version      : 1.74.0
URI          : https://az764295.vo.msecnd.net/stable/5235c6bb189b60b01b1f49062f4ffa42384f8c91/VSCodeSetup-x64-1.74.0.exe
Sha256       : fbe977aa69a1c1438d2c2b9d5525415e1fd8d97b6dbb149301a7c3bf3a84b14a
Platform     : win32-x64
Path         : \\server\EvergreenLibrary\MicrosoftVisualStudioCode\Stable\1.74.3\x64\VSCodeSetup-x64-1.74.0.exe
Channel      : Stable
Architecture : x64
```

This syntax can be simplified by passing details of the Evergreen library at `\\server\EvergreenLibrary` to `Get-EvergreenAppFromLibrary` via the pipeline to return details for Microsoft Visual Studio Code.

```powershell
PS C:\> Get-EvergreenLibrary -Path "\\server\EvergreenLibrary" | Get-EvergreenAppFromLibrary -Name "MicrosoftVisualStudioCode"

Version      : 1.74.3
URI          : https://az764295.vo.msecnd.net/stable/97dec172d3256f8ca4bfb2143f3f76b503ca0534/VSCodeSetup-x64-1.74.3.exe
Sha256       : cea32aa015116f8346e054c59497908f6da6059361c1b33d5b68059031f2dc97
Platform     : win32-x64
Path         : \\server\EvergreenLibrary\MicrosoftVisualStudioCode\Stable\1.74.3\x64\VSCodeSetup-x64-1.74.3.exe
Channel      : Stable
Architecture : x64

Version      : 1.74.0
URI          : https://az764295.vo.msecnd.net/stable/5235c6bb189b60b01b1f49062f4ffa42384f8c91/VSCodeSetup-x64-1.74.0.exe
Sha256       : fbe977aa69a1c1438d2c2b9d5525415e1fd8d97b6dbb149301a7c3bf3a84b14a
Platform     : win32-x64
Path         : \\server\EvergreenLibrary\MicrosoftVisualStudioCode\Stable\1.74.3\x64\VSCodeSetup-x64-1.74.0.exe
Channel      : Stable
Architecture : x64
```

Application information returned from an Evergreen library can be used in a script to install the latest available version (in this case) of Microsoft Visual Studio Code:

```powershell
$App = Get-EvergreenLibrary -Path "\\server\EvergreenLibrary" | Get-EvergreenAppFromLibrary -Name "MicrosoftVisualStudioCode" | Select-Object -First 1
$params = @{
    FilePath     = $App.Path
    ArgumentList = "/VERYSILENT /NOCLOSEAPPLICATIONS /NORESTARTAPPLICATIONS /NORESTART /SP- /SUPPRESSMSGBOXES /MERGETASKS=!runcode"
    NoNewWindow  = $true
    Wait         = $true
    PassThru     = $true
    ErrorAction  = "Continue"
}
Start-Process @params
```

Where a specific version of Visual Studio Code needs to be installed instead of the latest version, the specific version can be selected before installing:

```powershell
$App = Get-EvergreenLibrary -Path "\\server\EvergreenLibrary" | Get-EvergreenAppFromLibrary -Name "MicrosoftVisualStudioCode" | Where-Object { $_.Version -eq "1.74.0" }
$params = @{
    FilePath     = $App.Path
    ArgumentList = "/VERYSILENT /NOCLOSEAPPLICATIONS /NORESTARTAPPLICATIONS /NORESTART /SP- /SUPPRESSMSGBOXES /MERGETASKS=!runcode"
    NoNewWindow  = $true
    Wait         = $true
    PassThru     = $true
    ErrorAction  = "Continue"
}
Start-Process @params
```
