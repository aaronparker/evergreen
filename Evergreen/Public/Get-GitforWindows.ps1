Function Get-GitforWindows {
    <#
        .SYNOPSIS
            Returns the available Git for Windows versions.

        .DESCRIPTION
            Returns the available Git for Windows versions.

        .NOTES
            Author: Trond Eirik Haavarstein 
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Git

            Description:
            Returns the released Git version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param ()

    # Query the Git repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.GitforWindows.Uri
        ContentType = $script:resourceStrings.Applications.GitforWindows.ContentType
    }
    $Content = Invoke-WebContent @iwcParams
    $Json = $Content | ConvertFrom-Json
    $latestRelease = ($Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1

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
