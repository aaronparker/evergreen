Function Get-MicrosoftVisualStudioCode {
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
            Get-MicrosoftVsCode

            Description:
            Returns the Stable and Insider builds version numbers and download URLs for Windows, macOS and Linux.

        .EXAMPLE
            Get-MicrosoftVsCode -Channel stable -Platform win32-x64-user

            Description:
            Returns the Stable build version numbers and download URL for the user-install of VSCode for Windows.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('insider', 'stable')]
        [System.String[]] $Channel = @('insider', 'stable'),

        [Parameter()]
        [ValidateSet('darwin', 'win32', 'win32-user', 'win32-x64-user', 'win32-x64', `
                'win32-archive', 'win32-x64-archive', 'linux-deb-ia32', `
                'linux-deb-x64', 'linux-rpm-ia32', 'linux-ia32', 'linux-x64')]
        [System.String[]] $Platform = @('darwin', 'win32', 'win32-user', 'win32-x64-user', 'win32-x64', `
                'win32-archive', 'win32-x64-archive', 'linux-deb-ia32', `
                'linux-deb-x64', 'linux-rpm-ia32', 'linux-ia32', 'linux-x64')
    )

    # Walk through each platform
    ForEach ($plat in ($Platform | Sort-Object)) {
        Write-Verbose "Getting release info for $plat."

        # Walk through each channel in the platform
        ForEach ($ch in $Channel) {

            # Read the version details from the API, format and return to the pipeline
            $releaseJson = Invoke-WebContent -Uri "$($script:resourceStrings.Applications.MicrosoftVisualStudioCode.Uri)/$plat/$ch/VERSION" | `
                ConvertFrom-Json
            $PSObject = [PSCustomObject] @{
                Version  = $releaseJson.productVersion
                Platform = $plat
                Channel  = $ch
                URI      = $releaseJson.url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
