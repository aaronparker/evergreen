Function Get-MozillaFirefoxVersion {
    <#
        .SYNOPSIS
            Returns version numbers for various Mozilla Firefox release channels.

        .DESCRIPTION
            Returns version numbers for various Mozilla Firefox release channels using the official versions JSON.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Get.Software/

        .PARAMETER Channel
            Specify the release channel to return the Firefox version for.

        .EXAMPLE
            Get-MozillaFirefoxVersion

            Description:
            Returns version number for the release version of Mozilla Firefox.

        .EXAMPLE
            Get-MozillaFirefoxVersion -Channel dev

            Description:
            Returns version number for the development version of Mozilla Firefox.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = 'https://product-details.mozilla.org/1.0/firefox_versions.json',

        [Parameter(Mandatory = $False)]
        [ValidateSet('release', 'esr', 'dev', 'nightly')]
        [string] $Channel = "release"
    )

    # Read the JSON and convert to a PowerShell object. Return the version of Firefox
    $firefoxVersions = (Invoke-WebRequest -uri $Uri).Content | ConvertFrom-Json
    Switch ($Channel) {
        'nightly' { $output = $firefoxVersions.FIREFOX_NIGHTLY }
        'dev' { $output = $firefoxVersions.LATEST_FIREFOX_RELEASED_DEVEL_VERSION }
        'esr' { $output = $firefoxVersions.FIREFOX_ESR }
        'release' { $output = $firefoxVersions.LATEST_FIREFOX_VERSION }
        Default { $output = $firefoxVersions.LATEST_FIREFOX_VERSION }
    }
    Write-Output ([Version]::new($output))
}
