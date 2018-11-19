Function Get-MozillaFirefoxVersion {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
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