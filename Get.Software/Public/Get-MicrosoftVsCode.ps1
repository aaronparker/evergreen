Function Get-MicrosoftVsCode {
    <#
        .SYNOPSIS
            Returns Microsoft Visual Studio Code versions and download URLs.

        .DESCRIPTION
            Reads the Microsoft Visual Studio code update API to retrieve available Stable and Insider builds version numbers and download URLs for Windows, macOS and Linux.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

            Download URLs
            "https://aka.ms/win32-x64-user-stable"
            "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
            "https://vscode-update.azurewebsites.net/latest/win32-x64-user/stable"

        .LINK
            https://github.com/aaronparker/Get.Software/

        .PARAMETER Channel
            Specify the release channel to return Visual Studio Code details for. Specify Stable or Insider builds, or both.

        .PARAMETER Platform
            Specify the target platform to return Visual Studio Code details for. All supported platforms can be specified.

        .EXAMPLE
            Get-MicrosoftVsCodeVersion

            Description:
            Returns the Stable and Insider builds version numbers and download URLs for Windows, macOS and Linux.

        .EXAMPLE
            Get-MicrosoftVsCodeVersion -Channel stable -Platform win32-x64-user

            Description:
            Returns the Stable build version numbers and download URL for the user-install of VSCode for Windows.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('insider', 'stable')]
        [string[]] $Channel = @('insider', 'stable'),

        [Parameter()]
        [ValidateSet('darwin', 'win32', 'win32-user', 'win32-x64-user', 'win32-x64', `
                'win32-archive', 'win32-x64-archive', 'linux-deb-ia32', `
                'linux-deb-x64', 'linux-rpm-ia32', 'linux-ia32', 'linux-x64')]
        [string[]] $Platform = @('darwin', 'win32', 'win32-user', 'win32-x64-user', 'win32-x64', `
                'win32-archive', 'win32-x64-archive', 'linux-deb-ia32', `
                'linux-deb-x64', 'linux-rpm-ia32', 'linux-ia32', 'linux-x64'),

        [Parameter()]
        [ValidateSet('https://update.code.visualstudio.com/api/update')]
        [string[]] $Url = 'https://update.code.visualstudio.com/api/update'
    )

    # Output array
    $output = @()

    # Walk through each platform
    ForEach ($plat in $Platform) {
        Write-Verbose "Getting release info for $plat."

        # Walk through each channel in the platform
        ForEach ($ch in $Channel) {
            try {
                Write-Verbose "Getting release info for $ch."
                $release = Invoke-WebRequest -Uri "$url/$plat/$ch/VERSION" -UseBasicParsing `
                    -ErrorAction SilentlyContinue
            }
            catch {
                Write-Error "Error connecting to $url/$plat/$ch/VERSION, with error $_"
                Break
            }
            finally {
                $releaseJson = $release | ConvertFrom-Json
                Write-Verbose "Adding $plat $ch $($releaseJson.productVersion) to array."
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Channel' -Value $ch
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value $plat
                $item | Add-Member -Type NoteProperty -Name 'Version' -Value $releaseJson.productVersion
                $item | Add-Member -Type NoteProperty -Name 'Uri' -Value $releaseJson.url
                $output += $item
            }
        }
    }

    # Sort and return output to the pipeline
    Write-Output ($output | Sort-Object Channel, Platform | Format-Table)
}
