Function Get-AdobeReaderUri {
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
        [Parameter(Mandatory = $False)]
        [ValidateSet('win', 'mac')]
        [string[]] $Platform = "win"
    )

    # Get current version
    $version = (Get-AdobeReaderVersion).Replace('.', '')

    # Variables, URLs and languages for download
    $languages = @('en-US', 'de_DE', 'es_ES', 'fr_FR', 'ja_JP')
    $object = @()

    # Construct download list
    ForEach ($plat in $Platform) {
        Switch ($plat) {
            "win" {
                $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$plat/AcrobatDC/"
                ForEach ($lang in $languages) {
                    $item = New-Object PSCustomObject
                    $item | Add-Member -Type NoteProperty -Name 'Platform' -Value 'Windows'
                    $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Installer'
                    $item | Add-Member -Type NoteProperty -Name 'Language' -Value $lang
                    $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC$($version)_$($lang).exe"
                    $object += $item
                }
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value 'Windows'
                $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
                $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Neutral'
                $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC$($version).msp"
                $object += $item
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value 'Windows'
                $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
                $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
                $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC$($version)_MUI.msp"
                $object += $item
            }
            "mac" {
                $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$plat/AcrobatDC/"
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value 'macOS'
                $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Installer'
                $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
                $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC_$($version)_MUI.dmg"
                $object += $item
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value 'macOS'
                $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
                $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
                $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDCUpd$($version)_MUI.dmg"
                $object += $item
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Platform' -Value 'macOS'
                $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
                $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
                $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDCUpd$($version)_MUI.pkg"
                $object += $item
            }
        }
    }

    Write-Output ($object | Sort-Object -Property Platform, Type)
}
