Function Get-LibreOfficeUri {
    <#
        .SYNOPSIS
            Gets the latest Libre Office release URI.

        .DESCRIPTION
            Gets the latest Libre Office latest or Business release URI.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .PARAMETER Release
            Specify whether to return the Latest or Business release.

        .EXAMPLE
            Get-LibreOfficeUri

            Description:
            Returns the latest Libre Office for Windows download URI.

        .EXAMPLE
            Get-LibreOfficeUri -Release Business

            Description:
            Returns the latest business release Libre Office for Windows download URI.
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
