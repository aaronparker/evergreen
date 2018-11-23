<#
# macOS
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/darwin/insider/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/darwin/stable/VERSION" | ConvertFrom-Json

# Windows
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32/insider/VERSION" | ConvertFrom-Json

Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32/stable/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32-user/stable/VERSION" | ConvertFrom-Json

Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32-x64-user/stable/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32-x64/stable/VERSION" | ConvertFrom-Json

Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32-x64-archive/stable/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/win32-archive/stable/VERSION" | ConvertFrom-Json

# Linux
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/linux-deb-x64/insider/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/linux-deb-ia32/stable/VERSION" | ConvertFrom-Json

Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/linux-rpm-x64/insider/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/linux-rpm-ia32/stable/VERSION" | ConvertFrom-Json

Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/linux-x64/insider/VERSION" | ConvertFrom-Json
Invoke-WebRequest -Uri "https://update.code.visualstudio.com/api/update/linux-ia32/stable/VERSION" | ConvertFrom-Json

"https://vscode-update.azurewebsites.net/latest/win32-x64-user/stable"
"https://aka.ms/win32-x64-user-stable"
"https://update.code.visualstudio.com/latest/win32-x64-user/stable"

https://az764295.vo.msecnd.net/stable/bc24f98b5f70467bc689abf41cc5550ca637088e/VSCode-win32-x64-1.29.1.zip
#>
[CmdletBinding()]
Param()

$channels = @("insider", "stable")
$platforms = @("darwin", "win32", "win32-user", "win32-x64-user", "win32-x64", `
        "win32-x64-user", "win32-archive", "win32-x64-archive", "linux-deb-ia32", `
        "linux-deb-x64", "linux-rpm-ia32", "linux-ia32", "linux-x64")
$url = "https://update.code.visualstudio.com/api/update"

$output = @()
ForEach ($platform in $platforms) {
    Write-Verbose "Getting release info for $platform."
    ForEach ($channel in $channels) {
        Write-Verbose "Getting release info for $channel."
        $release = Invoke-WebRequest -Uri "$url/$platform/$channel/VERSION" -UseBasicParsing | ConvertFrom-Json
        $item = New-Object PSCustomObject
        $item | Add-Member -Type NoteProperty -Name 'Channel' -Value $channel
        $item | Add-Member -Type NoteProperty -Name 'Platform' -Value $platform
        $item | Add-Member -Type NoteProperty -Name 'Version' -Value $release.productVersion
        $item | Add-Member -Type NoteProperty -Name 'Uri' -Value $release.url
        $output += $item
    }
}

Write-Output ($output | Sort-Object Channel, Platform | Format-Table)
