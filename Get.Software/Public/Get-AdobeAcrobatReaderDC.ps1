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
            https://github.com/aaronparker/Get.Software

        .PARAMETER Platform
            Return downloads for Windows or macOS platforms. Use "win" or "mac" or specify both to return downloads for both platforms.

        .EXAMPLE
            Get-AdobeReaderUri -Platform

            Description:
            Returns an array with installer type, language and download URL for Windows.

        .EXAMPLE
            Get-AdobeReaderUri -Platform win, mac

            Description:
            Returns an array with installer type, language and download URL for both Windows and macOS.
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [ValidateSet("win", "mac")]
        [System.String[]] $Platform = "win"
    )

    # Get current version
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Uri `
        -ContentType $script:resourceStrings.Applications.AdobeAcrobatReaderDC.ContentType
    $version = $Content.Replace(".", "")

    # Construct download list
    If ($Null -ne $version) {
        ForEach ($plat in $Platform) {
            Switch ($plat) {
                "win" {
                    $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$plat/AcrobatDC/"
                    ForEach ($lang in $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Languages) {
                        $PSObject = [PSCustomObject] @{
                            Platform = "Windows"
                            Type     = "Installer"
                            Language = $lang
                            URL      = "$($ftpUrl)$($version)/AcroRdrDC$($version)_$($lang).exe"
                        }
                        Write-Output -InputObject $PSObject
                    }
                    $PSObject = [PSCustomObject] @{
                        Platform = "Windows"
                        Type     = "Updater"
                        Language = "Neutral"
                        URL      = "$($ftpUrl)$($version)/AcroRdrDC$($version).msp"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Platform = "Windows"
                        Type     = "Updater"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($version)/AcroRdrDC$($version)_MUI.msp"
                    }
                    Write-Output -InputObject $PSObject
                }
                "mac" {
                    $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$plat/AcrobatDC/"
                    $PSObject = [PSCustomObject] @{
                        Platform = "macOS"
                        Type     = "Installer"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($version)/AcroRdrDC_$($version)_MUI.dmg"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Platform = "macOS"
                        Type     = "Updater"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($version)/AcroRdrDCUpd$($version)_MUI.dmg"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Platform = "macOS"
                        Type     = "Updater"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($version)/AcroRdrDCUpd$($version)_MUI.pkg"
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to find Adobe Acrobat Reader DC version."
    }
}
