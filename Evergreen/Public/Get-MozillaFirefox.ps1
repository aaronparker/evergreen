Function Get-MozillaFirefox {
    <#
        .SYNOPSIS
            Returns downloads for the latest Mozilla Firefox releases.

        .DESCRIPTION
            Returns downloads for the latest Mozilla Firefox releases.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Evergreen/

        .PARAMETER Language
            Specify the Firefox language version to return.

        .PARAMETER Platform
            Specify the target platform to return Visual Studio Code details for. All supported platforms can be specified.

        .EXAMPLE
            Get-MozillaFirefoxUri

            Description:
            Returns the 64-bit English (US) download URI for Firefox for Windows.

        .EXAMPLE
            Get-MozillaFirefoxUri -Language en-GB -Platform mac

            Description:
            Returns the UK English download URI for Firefox for macOS.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [ValidateSet('win64', 'win32', 'mac', 'linux-x86_64', 'linux-i686')]
        [System.String[]] $Platform = @('win64', 'win32', 'mac', 'linux-x86_64', 'linux-i686'),

        [Parameter(Position = 1)]
        [ValidateSet('en-US', 'en-GB', 'en-CA', 'en-ZA', 'es-ES', 'es-AR', 'es-CL', 'es-MX', 'sv-SE', 'pt-BR', 'pt-PT', `
                'de', 'fr', 'it', 'ja', 'nl', 'zh-CN', 'zh-TW', 'ach', 'af', 'sq', 'ar', 'an', 'hy-AM', 'as', `
                'ast', 'az', 'eu', 'be', 'bn-BD', 'bn-IN', 'bs', 'br', 'bg', 'my', 'ca', 'hr', 'cs', `
                'da', 'eo', 'et', 'fi', 'fy-NL', 'ff', 'gd', 'gl', 'ka', 'el', 'gn', 'gu-IN', 'he', 'hi-IN', `
                'hu', 'is', 'id', 'ia', 'ga-IE', 'kab', 'kn', 'cak', 'kk', 'km', 'ko', 'lv', 'lij', 'lt', `
                'dsb', 'mk', 'mai', 'ms', 'ml', 'mr', 'ne-NP', 'nb-NO', 'nn-NO', 'oc', 'or', 'fa', 'pl', 'pa-IN', `
                'ro', 'rm', 'ru', 'sr', 'si', 'sk', 'sl', 'son', 'ta', 'te', 'th', 'tr', 'uk', 'hsb', 'ur', `
                'uz', 'vi', 'cy', 'xh')]
        [System.String[]] $Language = 'en-US'
    )

    # Get latest Firefox version
    $firefoxVersions = Invoke-WebContent -Uri $script:resourceStrings.Applications.MozillaFirefox.Uri | ConvertFrom-Json
    $version = ([Version]::new($firefoxVersions.LATEST_FIREFOX_VERSION))

    # Construct custom object with output details
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

            # Build object and output to the pipeline
            $PSObject = [PSCustomObject] @{
                Version  = $version
                Platform = $plat
                Language = $lang
                Filename = $file.Replace('%20', ' ')
                URI      = "$($script:resourceStrings.Applications.MozillaFirefox.DownloadUri)$($version)/$($plat)/$($lang)/$($file)"
            }
            Write-Output -InputObject $PSObject
        }
    }
}
