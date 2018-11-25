Function Get-MicrosoftVsCode {
    <#
        .SYNOPSIS
            Returns Microsoft Visual Studio Code versions and dowmload URLs.

        .DESCRIPTION
            Reads the Microsoft Visual Studio code update API to retrieve available Stable and Insider builds version numbers and download URLs for Windows, macOS and Linux.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Get.Software/

        .EXAMPLE
            Get-MicrosoftVsCodeVersion

            Description:
            Returns the Stable and Insider builds version numbers and download URLs for Windows, macOS and Linux.
    #>
    <#
        "https://aka.ms/win32-x64-user-stable"
        "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
        "https://vscode-update.azurewebsites.net/latest/win32-x64-user/stable"
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('insider', 'stable')]
        [string[]]
        $Channels = @('insider', 'stable'),

        [Parameter()]
        [ValidateSet('darwin', 'win32', 'win32-user', 'win32-x64-user', 'win32-x64', `
                'win32-x64-user', 'win32-archive', 'win32-x64-archive', 'linux-deb-ia32', `
                'linux-deb-x64', 'linux-rpm-ia32', 'linux-ia32', 'linux-x64')]
        [string[]]
        $Platforms = @('darwin', 'win32', 'win32-user', 'win32-x64-user', 'win32-x64', `
                'win32-x64-user', 'win32-archive', 'win32-x64-archive', 'linux-deb-ia32', `
                'linux-deb-x64', 'linux-rpm-ia32', 'linux-ia32', 'linux-x64'),

        [Parameter()]
        [ValidateSet('https://update.code.visualstudio.com/api/update')]
        [string[]]
        $Url = 'https://update.code.visualstudio.com/api/update'
    )

    # Output array
    $output = @()

    # Walk through each platform
    ForEach ($platform in $platforms) {
        Write-Verbose "Getting release info for $platform."

        # Walk through each channel in the platform
        ForEach ($channel in $channels) {
            try {
                Write-Verbose "Getting release info for $channel."
                $release = Invoke-WebRequest -Uri "$url/$platform/$channel/VERSION" -UseBasicParsing `
                    -ErrorAction SilentlyContinue
            }
            catch {
                Write-Error "Error connecting to $url/$platform/$channel/VERSION, with error $_"
                Break
            }
            finally {
                $releaseJson = $release | ConvertFrom-Json
                Write-Verbose "Adding $platform $channel $($releaseJson.productVersion) to array."
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Channel' -Value $channel
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value $platform
                $item | Add-Member -Type NoteProperty -Name 'Version' -Value $releaseJson.productVersion
                $item | Add-Member -Type NoteProperty -Name 'Uri' -Value $releaseJson.url
                $output += $item
            }
        }
    }

    # Sort and return output to the pipeline
    Write-Output ($output | Sort-Object Channel, Platform | Format-Table)
}
