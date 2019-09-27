Function Get-MicrosoftPowerShellCore {
    <#
        .SYNOPSIS
            Returns the latest PowerShell Core version number.

        .DESCRIPTION
            Returns the latest PowerShell Core version number.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-PowerShellCoreVersion

            Description:
            Returns the latest PowerShell Core version number.
    #>
    [CmdletBinding()]
    Param()

    # Get latest version and download latest PowerShell Core release via GitHub API
    # Query the PowerShell Core repository for releases, keeping the latest stable release
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.MicrosoftPowerShellCore.Uri `
        -ContentType $script:resourceStrings.Applications.MicrosoftPowerShellCore.ContentType -Raw
    $JsonReleases = $Content | ConvertFrom-Json
    $LatestRelease = $JsonReleases | Where-Object { $_.prerelease -eq $False } | Select-Object -First 1

    # Build the output object with release details
    ForEach ($release in $latestRelease.assets) {
        $PSObject = [PSCustomObject] @{
            Version      = $LatestRelease.tag_name
            Platform     = "Platform"
            Architecture = "x64"
            URI          = $release.browser_download_url
            Size         = $release.size
        }
        Write-Output -InputObject $PSObject
    }
}
