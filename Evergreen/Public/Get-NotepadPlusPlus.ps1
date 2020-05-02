Function Get-NotepadPlusPlus {
    <#
        .SYNOPSIS
            Returns the latest Notepad++ version and download URI.

        .DESCRIPTION
            Returns the latest Notepad++ version and download URI.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-NotepadPlusPlus

            Description:
            Returns the latest x86 and x64 Notepad++ version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest Notepad++ release via GitHub API
    # Query the Notepad++ repository for releases, keeping the latest stable release
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

            # Filter for .exe
            If (($release.content_type -eq "application/x-msdownload")) {

                Switch -Regex ($release.browser_download_url) {
                    "amd64" { $arch = "AMD64" }
                    "arm64" { $arch = "ARM64" }
                    "arm32" { $arch = "ARM32" }
                    "x86_64" { $arch = "x86_64" }
                    "x64" { $arch = "x64" }
                    "-x86" { $arch = "x86" }
                    Default { $arch = "x86" }
                }

                Switch -Regex ($release.browser_download_url) {
                    "win" { $platform = "Windows" }
                    Default { $platform = "Windows" }
                }

                # Build and array of the latest release and download URLs
                $PSObject = [PSCustomObject] @{
                    Version      = [RegEx]::Match($latestRelease.tag_name, $res.Get.MatchVersion).Captures.Groups[1].Value
                    Platform     = $platform
                    Architecture = $arch
                    Date         = ConvertTo-DateTime -DateTime $release.created_at
                    Size         = $release.size
                    URI          = $release.browser_download_url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
