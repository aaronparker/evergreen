Function Get-LibreOfficeUri {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [ValidateSet("Latest", "Business")]
        [string] $Release = "Latest"
    )

    # Get current version number using Get-LibreOfficeVersion
    $currentVersion = Get-LibreOfficeVersion -Release $Release

    $rootUrl = "https://download.documentfoundation.org/libreoffice/stable/"
    $downloadURL = "$rootUrl$($CurrentVersion.ToString())/win/x86_64/LibreOffice_$($CurrentVersion.tostring())_Win_x64.msi"

    Write-Output $downloadURL
}
