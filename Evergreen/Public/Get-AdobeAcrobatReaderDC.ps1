Function Get-AdobeAcrobatReaderDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Reader DC Continuous track installers.

        .DESCRIPTION
            Gets the download URLs for Adobe Reader DC Continuous track installers for the latest version for Windows and macOS.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-AdobeAcrobatReaderDC

            Description:
            Returns an array with version, installer type, language and download URL for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    #region Installer downloads
    ForEach ($platform in $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Platforms) {
        ForEach ($language in $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Languages) {
            Write-Verbose -Message "Searching: [$($platform.platform_type)] [$language]"
            $Uri = $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Uri -replace "#Platform", $platform.platform_type
            $Uri = $Uri -replace "#Dist", $platform.platform_dist
            $Uri = $Uri -replace "#Language", $language
            $Uri = $Uri -replace "#Arch", $platform.platform_arch
            $Uri = $Uri -replace " ", "%20"
            $iwcParams = @{
                Uri             = $Uri
                Headers         = $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Headers
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            #$Content = Invoke-WebContent @iwcParams
            $Content = Invoke-WebRequest @iwcParams

            If ($Null -ne $Content) {
                $ContentFromJson = $Content.Content | ConvertFrom-Json
                
                # Check properties if multiple values returned
                If ($ContentFromJson.version.Count -eq 1) { $Version = $ContentFromJson.version } Else { $Version = $ContentFromJson.version | Select-Object -First 1 }
                If ($ContentFromJson.download_url.Count -eq 1) { $URI = $ContentFromJson.download_url } Else { $URI = $ContentFromJson.download_url | Select-Object -First 1 }
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Platform = $platform.platform_type
                    Type     = "Installer"
                    Language = $language
                    URI      = $URI
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion

    #region Update downloads
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.AdobeAcrobatReaderDC.UpdateUri
        ContentType = $script:resourceStrings.Applications.AdobeAcrobatReaderDC.UpdateContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # Construct update download list
    If ($Null -ne $Content) {
        $versionString = $Content.Replace(".", "")
        ForEach ($platform in $script:resourceStrings.Applications.AdobeAcrobatReaderDC.UpdatePlatforms) {
            Switch ($platform) {
                "win" {
                    $updateUrl = $script:resourceStrings.Applications.AdobeAcrobatReaderDC.UpdateDownloadUri -replace "#Platform", $platform
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Windows"
                        Type     = "Updater"
                        Language = "Neutral"
                        URI      = "$($updateUrl)$($versionString)/AcroRdrDC$($versionString).msp"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Windows"
                        Type     = "Updater"
                        Language = "Multi"
                        URI      = "$($updateUrl)$($versionString)/AcroRdrDC$($versionString)_MUI.msp"
                    }
                    Write-Output -InputObject $PSObject
                }
                "mac" {
                    $updateUrl = $script:resourceStrings.Applications.AdobeAcrobatReaderDC.UpdateDownloadUri -replace "#Platform", $platform
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Macintosh"
                        Type     = "Installer"
                        Language = "Multi"
                        URI      = "$($updateUrl)$($versionString)/AcroRdrDC_$($versionString)_MUI.dmg"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Macintosh"
                        Type     = "Updater"
                        Language = "Multi"
                        URI      = "$($updateUrl)$($versionString)/AcroRdrDCUpd$($versionString)_MUI.dmg"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Macintosh"
                        Type     = "Updater"
                        Language = "Multi"
                        URI      = "$($updateUrl)$($versionString)/AcroRdrDCUpd$($versionString)_MUI.pkg"
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to find Adobe Acrobat Reader DC version."
    }
    #endregion
}
