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

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest PowerShell Core release via GitHub API
    # Query the PowerShell Core repository for releases, keeping the latest stable release
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
        Raw         = $True
    }
    $Content = Invoke-WebContent @iwcParams

    If ($Null -ne $Content) {
        $json = $Content | ConvertFrom-Json
        $releases = $json | Where-Object { $_.prerelease -ne $True }
        $latestRelease = $releases | Select-Object -First 1

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
            $latestRelease.tag_name -match $res.Get.MatchVersion | Out-Null
            $Version = $Matches[0]

            # Build and array of the latest release and download URLs
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
}
