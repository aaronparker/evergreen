Function Get-BISF {
    <#
        .SYNOPSIS
            Returns the available Base Image Script Framework versions.

        .DESCRIPTION
            Returns the available Base Image Script Framework versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-BISF

            Description:
            Returns the released Base Image Script Framework version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Query the BIS-F repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.BISF.Uri
        ContentType = $script:resourceStrings.Applications.BISF.ContentType
    }
    $Content = Invoke-WebContent @iwcParams
    $latestRelease = ($Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1

    # Build and array of the latest release and download URLs
    $releases = $latestRelease.assets
    ForEach ($release in $releases) {
        $PSObject = [PSCustomObject] @{
            Version = $latestRelease.tag_name
            Date         = ([DateTime]::ParseExact($release.created_at, 'MM/dd/yyyy HH:mm:ss', [CultureInfo]::InvariantCulture))
            Size    = $release.size
            URI     = $release.browser_download_url
        }
        Write-Output -InputObject $PSObject
    }
}
