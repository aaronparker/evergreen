Function Get-AdobeReaderVersion {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt"
    )

    # Get current version
    Write-Output $(((Invoke-WebRequest -uri $Uri).Content).Replace('.', ''))
}