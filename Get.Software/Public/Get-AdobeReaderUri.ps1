Function Get-AdobeReaderUri {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt",

        [Parameter(Mandatory = $False)]
        [ValidateSet('win', 'mac')]
        [string] $Platform = "win"
    )

    # Get current version
    $version = ((Invoke-WebRequest -uri $Uri).Content).Replace('.', '')

    # Variables, URLs and languages for download
    $ftpUrl = "ftp://ftp.adobe.com/pub/adobe/reader/$Platform/AcrobatDC/"
    $languages = @('en-US', 'de_DE', 'es_ES', 'fr_FR', 'ja_JP')
    $object = @()

    # Construct download list
    Switch ($Platform) {
        "win" {
            ForEach ($lang in $languages) {
                $item = New-Object PSCustomObject
                $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Installer'
                $item | Add-Member -Type NoteProperty -Name 'Language' -Value $lang
                $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC$($version)_$($lang).exe"
                $object += $item
            }
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
            $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Neutral'
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC$($version).msp"
            $object += $item
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
            $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC$($version)_MUI.msp"
            $object += $item
        }
        "mac" {
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Installer'
            $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDC_$($version)_MUI.dmg"
            $object += $item
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
            $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDCUpd$($version)_MUI.dmg"
            $object += $item
            $item = New-Object PSCustomObject
            $item | Add-Member -Type NoteProperty -Name 'Type' -Value 'Updater'
            $item | Add-Member -Type NoteProperty -Name 'Language' -Value 'Multi'
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value "$($ftpUrl)$($version)/AcroRdrDCUpd$($version)_MUI.pkg"
            $object += $item
        }
    }

    Write-Output $object
}