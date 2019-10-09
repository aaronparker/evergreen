Function Get-LibreOffice {
    <#
        .SYNOPSIS
            Gets the latest Libre Office version and release URI.

        .DESCRIPTION
            Gets the latest Libre Office latest or Business release version and URI.

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

    # Libre Office download URL
    $url = "https://www.libreoffice.org/download/download/"

    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Failed to connect to Libre Office URL: $url with error $_."
        Break
    }
    finally {
        # Search for their big green logo version number '<span class="dl_version_number">*</span>'
        $content = $response.Content
        $spans = $content.Replace('<span', '#$%^<span').Replace('</span>', '</span>#$%^').Split('#$%^') | `
                Where-Object { $_ -like '<span class="dl_version_number">*</span>' }
        $verBlock = ($spans).Replace('<span class="dl_version_number">', '').Replace('</span>', '')

        If ($Release -eq "Latest") {
            $version = [version]::new($($verblock | Select-Object -First 1))
        }
        Else {
            $version = [version]::new($($verblock | Select-Object -Last 1))
        }
    }

    # Write version and download the pipeline
    $rootUrl = "https://download.documentfoundation.org/libreoffice/stable/"
    $downloadURL = "$rootUrl$($version.ToString())/win/x86_64/LibreOffice_$($version.ToString())_Win_x64.msi"
    $PSObject = [PSCustomObject] @{
        Version = $version.ToString()
        URI     = $downloadURL
    }
    Write-Output -InputObject $PSObject
}
