Function Get-MozillaFirefoxVersion {
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
    Write-Output $output
}

Function Get-MozillaFirefoxUri {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        [ValidateSet('en-US', 'en-GB', 'en-CA', 'en-ZA', 'es-ES', 'es-AR', 'es-CL', 'es-MX', 'sv-SE', 'pt-BR', 'pt-PT', `
                'de', 'fr', 'it', 'ja', 'nl', 'zh-CN', 'zh-TW', 'ach', 'af', 'sq', 'ar', 'an', 'hy-AM', 'as', `
                'ast', 'az', 'eu', 'be', 'bn-BD', 'bn-IN', 'bs', 'br', 'bg', 'my', 'ca', 'hr', 'cs', `
                'da', 'eo', 'et', 'fi', 'fy-NL', 'ff', 'gd', 'gl', 'ka', 'el', 'gn', 'gu-IN', 'he', 'hi-IN', `
                'hu', 'is', 'id', 'ia', 'ga-IE', 'kab', 'kn', 'cak', 'kk', 'km', 'ko', 'lv', 'lij', 'lt', `
                'dsb', 'mk', 'mai', 'ms', 'ml', 'mr', 'ne-NP', 'nb-NO', 'nn-NO', 'oc', 'or', 'fa', 'pl', 'pa-IN', `
                'ro', 'rm', 'ru', 'sr', 'si', 'sk', 'sl', 'son', 'ta', 'te', 'th', 'tr', 'uk', 'hsb', 'ur', `
                'uz', 'vi', 'cy', 'xh')]
        [String[]] $Language = 'en-US',

        [Parameter(Mandatory = $False)]
        [ValidateSet('win64', 'win32', 'mac', 'linux-x86_64', 'linux-i686')]
        [String[]] $Platform = 'win64'
    )

    # Get latest Firefox version
    $version = Get-MozillaFirefoxVersion
    $url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/"

    # Construct custom object with output details
    $object = @()
    ForEach ($lang in $Language) {
        ForEach ($plat in $Platform) {

            # Select the download file for the selected platform
            Switch ($plat) {
                "win64" { $file = "Firefox%20Setup%20$($version).exe" }
                "win32" { $file = "Firefox%20Setup%20$($version).exe" }
                "mac" { $file = "Firefox%20$($version).dmg" }
                "linux-x86_64" { $file = "firefox-$($version).tar.bz2" }
                "linux-i686" { $file = "firefox-$($version).tar.bz2" }
            }

            # Build the output object with properties
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Platform' -Value $plat
            $item | Add-Member -Type NoteProperty -Name 'Language' -Value $lang
            $item | Add-Member -Type NoteProperty -Name 'Filename' -Value $file.Replace('%20', ' ')
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$url$($version)/$($plat)/$($lang)/$($file)"
            $object += $item
        }
    }

    # Return output
    Write-Output $object
}