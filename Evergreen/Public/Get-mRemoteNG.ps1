Function Get-mRemoteNG {
    <#
        .SYNOPSIS
            Returns the available mRemoteNG versions.

        .DESCRIPTION
            Returns the available mRemoteNG versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-mRemoteNG

            Description:
            Returns the released mRemoteNG version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Query the mRemoteNG repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.mRemoteNG.Uri
        ContentType = $script:resourceStrings.Applications.mRemoteNG.ContentType
    }
    $Content = Invoke-WebContent @iwcParams
    $latestRelease = ($Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1

    # Build and array of the latest release and download URLs
    $releases = $latestRelease.assets
    ForEach ($release in $releases) {
        $PSObject = [PSCustomObject] @{
            Version = $latestRelease.tag_name
            Date    = (ConvertTo-DateTime -DateTime $release.created_at)
            Size    = $release.size
            URI     = $release.browser_download_url
        }
        Write-Output -InputObject $PSObject
    }
}
