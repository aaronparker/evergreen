Function Get-ShareX {
    <#
        .SYNOPSIS
            Returns the available ShareX versions.

        .DESCRIPTION
            Returns the available ShareX versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ShareX

            Description:
            Returns the released ShareX version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Query the ShareX repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.ShareX.Uri
        ContentType = $script:resourceStrings.Applications.ShareX.ContentType
    }
    $Content = Invoke-WebContent @iwcParams
    $latestRelease = ($Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1

    # Build and array of the latest release and download URLs
    $releases = $latestRelease.assets
    ForEach ($release in $releases) {
        $PSObject = [PSCustomObject] @{
            # TODO: use RegEx to extract version number rather than -replace
            Version = ($latestRelease.tag_name -replace "v", "")
            Date    = (ConvertTo-DateTime -DateTime $release.created_at)
            Size    = $release.size
            URI     = $release.browser_download_url
        }
        Write-Output -InputObject $PSObject
    }
}
