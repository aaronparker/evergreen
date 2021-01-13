Function Get-MicrosoftVisualStudioCode {
    <#
        .SYNOPSIS
            Returns Microsoft Visual Studio Code versions and download URLs.

        .DESCRIPTION
            Reads the Microsoft Visual Studio code update API to retrieve available Stable and Insider builds version numbers and download URLs for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

            Download URLs
            "https://aka.ms/win32-x64-user-stable"
            "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
            "https://vscode-update.azurewebsites.net/latest/win32-x64-user/stable"

        .LINK
            https://github.com/aaronparker/Evergreen/

        .PARAMETER Channel
            Specify the release channel to return Visual Studio Code details for. Specify Stable or Insider builds, or both.

        .PARAMETER Platform
            Specify the target platform to return Visual Studio Code details for. All supported platforms can be specified.

        .EXAMPLE
            Get-MicrosoftVisualStudioCode

            Description:
            Returns the Stable and Insider builds version numbers and download URLs for Windows.

        .EXAMPLE
            Get-MicrosoftVisualStudioCode -Channel stable -Platform win32-x64-user

            Description:
            Returns the Stable build version numbers and download URL for the user-install of VSCode for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('insider', 'stable')]
        [System.String[]] $Channel = @('stable'),

        [Parameter()]
        [ValidateSet('win32', 'win32-user', 'win32-x64-user', 'win32-x64')]
        [System.String[]] $Platform = @('win32', 'win32-user', 'win32-x64-user', 'win32-x64')
    )

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Walk through each platform
    ForEach ($plat in ($Platform | Sort-Object)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Getting release info for $plat."

        # Walk through each channel in the platform
        ForEach ($ch in $Channel) {

            # Read the version details from the API, format and return to the pipeline
            $releaseJson = Invoke-WebContent -Uri "$($res.Get.Uri)/$plat/$ch/VERSION" | ConvertFrom-Json
            $PSObject = [PSCustomObject] @{
                Version      = $releaseJson.productVersion
                Platform     = $plat
                Architecture = Get-Architecture -String $releaseJson.url
                Channel      = $ch
                Sha256       = $releaseJson.sha256hash
                URI          = $releaseJson.url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
