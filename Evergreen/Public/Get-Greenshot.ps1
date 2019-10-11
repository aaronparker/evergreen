Function Get-Greenshot {
    <#
        .SYNOPSIS
            Returns the available Greenshot versions.

        .DESCRIPTION
            Returns the available Greenshot versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Greenshot

            Description:
            Returns the released Greenshot version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Query the Greenshot repository for releases, keeping the latest release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.Greenshot.Uri
        ContentType = $script:resourceStrings.Applications.Greenshot.ContentType
    }
    $Content = Invoke-WebContent @iwcParams
    $latestRelease = ($Content | ConvertFrom-Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1 

    # Latest version number 'Greenshot-RELEASE-1.2.10.6'
    $latestRelease.tag_name -match $script:resourceStrings.Applications.Greenshot.MatchVersion | Out-Null
    $latestVersion = $Matches[0]

    # Build and array of the latest release and download URLs
    $releases = $latestRelease.assets | Where-Object { $_.name -like "Greenshot*" }
    ForEach ($release in $releases) {
        $PSObject = [PSCustomObject] @{
            Version = $latestVersion
            Date         = ([DateTime]::ParseExact($release.created_at, 'MM/dd/yyyy HH:mm:ss', [CultureInfo]::InvariantCulture))
            Size    = $release.size
            URI     = $release.browser_download_url
        }
        Write-Output -InputObject $PSObject
    }
}

