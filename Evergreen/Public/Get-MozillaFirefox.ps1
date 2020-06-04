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
            Get-MozillaFirefox

            Description:
            Returns the version and download URIs for Firefox for Windows.

        .EXAMPLE
            Get-MozillaFirefox -Language en-GB

            Description:
            Returns the UK English version and download URIs for Firefox for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [ValidateSet('win64', 'win32')]
        [System.String[]] $Platform = @('win64', 'win32'),

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

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest Firefox version
    $firefoxVersions = Invoke-WebContent -Uri $res.Get.Update.Uri | ConvertFrom-Json
    
    # Construct custom object with output details
    ForEach ($lang in $Language) {
        ForEach ($plat in $Platform) {
            ForEach ($channel in $res.Get.Update.Channels) {

                # Select the download file for the selected platform
                Switch ($plat) {
                    "win64" { $file = "Firefox%20Setup%20$($firefoxVersions.$channel).exe" }
                    "win32" { $file = "Firefox%20Setup%20$($firefoxVersions.$channel).exe" }
                }

                # Build object and output to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = $firefoxVersions.$channel
                    Architecture = Get-Architecture -String $plat
                    Language     = $lang
                    Filename     = $file.Replace('%20', ' ')
                    URI          = "$($res.Get.DownloadUri)$($firefoxVersions.$channel)/$($plat)/$($lang)/$($file)"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
