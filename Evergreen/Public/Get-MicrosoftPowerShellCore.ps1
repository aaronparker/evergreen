Function Get-MicrosoftPowerShellCore {
    <#
        .SYNOPSIS
            Returns the latest PowerShell Core version number and download.

        .DESCRIPTION
            Returns the latest PowerShell Core version number and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftPowerShellCore

            Description:
            Returns the latest PowerShell Core version number and download for each platform.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get latest version and download latest PowerShell Core release via GitHub API
    # Query the PowerShell Core repository for releases, keeping the latest stable release
    $iwcParams = @{
        Uri         = $script:resourceStrings.Applications.MicrosoftPowerShellCore.Uri
        ContentType = $script:resourceStrings.Applications.MicrosoftPowerShellCore.ContentType
        Raw         = $True
    }
    $Content = Invoke-WebContent @iwcParams
    $Json = $Content | ConvertFrom-Json
    $latestRelease = ($Json | Where-Object { $_.prerelease -eq $False }) | Select-Object -First 1

    # Build the output object with release details
    ForEach ($release in $latestRelease.assets) {

        Switch -Regex ($release.browser_download_url) {
            "amd64" { $arch = "AMD64" }
            "arm64" { $arch = "ARM64" }
            "arm32" { $arch = "ARM32" }
            "x86_64" { $arch = "x86_64" }
            "x64" { $arch = "x64" }
            "-x86" { $arch = "x86" }
            "fxdependent" { $arch = "fxdependent" }
            Default { $arch = "Unknown" }
        }

        Switch -Regex ($release.browser_download_url) {
            "rhel" { $platform = "RHEL" }
            "linux" { $platform = "Linux" }
            "win" { $platform = "Windows" }
            "osx" { $platform = "macOS" }
            "debian" { $platform = "Debian" }
            "ubuntu" { $platform = "Ubuntu" }
            Default { $platform = "Unknown" }
        }

        # Match version number
        $latestRelease.tag_name -match $script:resourceStrings.Applications.MicrosoftPowerShellCore.MatchVersion | Out-Null
        $Version = $Matches[0]

        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Platform     = $platform
            Architecture = $arch
            Date         = (ConvertTo-DateTime -DateTime $release.created_at)
            Size         = $release.size
            URI          = $release.browser_download_url
        }
        Write-Output -InputObject $PSObject
    }
}
