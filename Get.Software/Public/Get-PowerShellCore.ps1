Function Get-PowerShellCore {
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
    [OutputType([Version])]
    Param()

    # Get latest version and download latest PowerShell Core release via GitHub API

    # GitHub API to query for PowerShell Core repository
    $repo = "PowerShell/PowerShell"
    $releases = "https://api.github.com/repos/$repo/releases"

    # Query the PowerShell Core repository for releases, keeping the latest release
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $latestRelease = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json | `
            Where-Object { $_.prelease -eq $False })[0]

    # Latest version number
    $latestVersion = $latestRelease.tag_name
    Write-Output $latestVersion

    # Array of releases and downloaded
    $releases = $latestRelease.assets | Where-Object { $_.name -like "PowerShell Core*" } | `
        Select-Object name, browser_download_url
    Write-Output $releases
}
