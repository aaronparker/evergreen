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

        .EXAMPLE
            Get-MozillaFirefox

            Description:
            Returns the version and download URIs for Firefox for Windows (en-US).

        .EXAMPLE
            Get-MozillaFirefox -Language en-GB

            Description:
            Returns the UK English version and download URIs for Firefox for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
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
    $firefoxVersions = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    
    # Construct custom object with output details
    ForEach ($lang in $Language) {
        ForEach ($channel in $res.Get.Update.Channels) {
            ForEach ($platform in $res.Get.Download.Platforms) {

                # Select the download file for the selected platform
                ForEach ($installer in $res.Get.Download.Uri[$channel].GetEnumerator()) {
                    $params = @{
                        Uri = (($res.Get.Download.Uri[$channel][$installer.Key] -replace $res.Get.Download.Text.Platform, $platform) -replace $res.Get.Download.Text.Language, $lang)
                    }
                    $response = Resolve-Uri @params

                    # Build object and output to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version      = $firefoxVersions.$channel -replace "esr", ""
                        Architecture = Get-Architecture -String $platform
                        Channel      = $channel
                        Language     = $lang
                        Type         = [System.IO.Path]::GetExtension($response.ResponseUri.AbsoluteUri).Split(".")[-1]
                        Filename     = (Split-Path -Path $response.ResponseUri.AbsoluteUri -Leaf).Replace('%20', ' ')
                        URI          = $response.ResponseUri.AbsoluteUri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
