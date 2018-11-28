Function Get-AdobeReaderVersion {
    <#
        .SYNOPSIS
            Gets the current Adobe Reader DC Continuous track release version.

        .DESCRIPTION
            Gets the current Adobe Reader DC Continuous track release version sourced from the Adobe site and returns a version string.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-AdobeReaderVersion

            Description:
            Returns the version number string for the latest Adobe Reader DC release.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://armmf.adobe.com/arm-manifests/mac/AcrobatDC/reader/current_version.txt"
    )

    # Get current version
    Write-Output ((Invoke-WebRequest -uri $Uri).Content)
}
