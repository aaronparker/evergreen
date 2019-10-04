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

        .PARAMETER Platform
            Return downloads for Windows or macOS platforms. Use "win" or "mac" or specify both to return downloads for both platforms.

        .EXAMPLE
            Get-AdobeAcrobatReaderDC -Platform

            Description:
            Returns an array with version, installer type, language and download URL for Windows.

        .EXAMPLE
            Get-AdobeAcrobatReaderDC -Platform win, mac

            Description:
            Returns an array with version, installer type, language and download URL for both Windows and macOS.
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

    # Construct download list
    If ($Null -ne $Content) {
        $versionString = $Content.Replace(".", "")
        ForEach ($plat in $Platform) {
            Switch ($plat) {
                "win" {
                    $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$plat/AcrobatDC/"
                    ForEach ($lang in $script:resourceStrings.Applications.AdobeAcrobatReaderDC.Languages) {
                        $PSObject = [PSCustomObject] @{
                            Version  = $Content
                            Platform = "Windows"
                            Type     = "Installer"
                            Language = $lang
                            URL      = "$($ftpUrl)$($versionString)/AcroRdrDC$($versionString)_$($lang).exe"
                        }
                        Write-Output -InputObject $PSObject
                    }
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Windows"
                        Type     = "Updater"
                        Language = "Neutral"
                        URL      = "$($ftpUrl)$($versionString)/AcroRdrDC$($versionString).msp"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "Windows"
                        Type     = "Updater"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($versionString)/AcroRdrDC$($versionString)_MUI.msp"
                    }
                    Write-Output -InputObject $PSObject
                }
                "mac" {
                    $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$plat/AcrobatDC/"
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "macOS"
                        Type     = "Installer"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($versionString)/AcroRdrDC_$($versionString)_MUI.dmg"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "macOS"
                        Type     = "Updater"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($versionString)/AcroRdrDCUpd$($versionString)_MUI.dmg"
                    }
                    Write-Output -InputObject $PSObject
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Platform = "macOS"
                        Type     = "Updater"
                        Language = "Multi"
                        URL      = "$($ftpUrl)$($versionString)/AcroRdrDCUpd$($versionString)_MUI.pkg"
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
