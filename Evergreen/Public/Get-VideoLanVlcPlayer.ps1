Function Get-VideoLanVlcPlayer {
    <#
        .SYNOPSIS
            Get the current version and download URL for VideoLAN VLC Media Player.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-VideoLanVlcPlayer

            Description:
            Returns the current version and download URLs for VLC Media Player on Windows (x86, x64) and macOS.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    #region Get current version for macOS
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.VideoLanVlcPlayer.Uri.macOS
    If ($Null -ne $Content) {
        try {
            $xml = [System.XML.XMLDocument] $Content
            $latest = $xml.rss.channel.item | Select-Object -Last 1
            $version = $latest.title.Trim("Version ")
        }
        catch {
            Write-Verbose -Message "Error reading the update URL and converting to XML."
        }

        # Follow the URL returned to get the actual download URI
        If (Test-PSCore) {
            $URI = "https://get.videolan.org/vlc/$version/macosx/vlc-$version.dmg"
            Write-Warning -Message "PowerShell Core: skipping follow URL: $URI."
        }
        Else {
            $iwrParams = @{
                Uri                = "https://get.videolan.org/vlc/$version/macosx/vlc-$version.dmg"
                UserAgent          = $script:resourceStrings.Applications.VideoLanVlcPlayer.UserAgent
                MaximumRedirection = 0
                UseBasicParsing    = $True
                ErrorAction        = "SilentlyContinue"
            }
            $Response = Invoke-WebRequest @iwrParams
            $URI = $Response.Links[0].href
        }

        # Construct the output; Return the custom object to the pipeline
        ForEach ($extension in $script:resourceStrings.Applications.VideoLanVlcPlayer.Extensions.macOS) {
            $PSObject = [PSCustomObject] @{
                Version      = $version
                Platform     = "macOS"
                Architecture = "x64"
                Type         = $extension
                URI          = $URI
            }
            Write-Output -InputObject $PSObject
        }
    }
    #endregion

    #region Get current version for Windows
    ForEach ($platform in $script:resourceStrings.Applications.VideoLanVlcPlayer.Uri.Windows.GetEnumerator()) {
        $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.VideoLanVlcPlayer.Uri.Windows[$platform.Key] -Raw

        # Follow the URL returned to get the actual download URI
        If ($Null -ne $Content) {
            If (Test-PSCore) {
                $URI = $Content[1]
                Write-Warning -Message "PowerShell Core: skipping follow URL: $URI."
            }
            Else {
                $iwrParams = @{
                    Uri                = $Content[1]
                    UserAgent          = $script:resourceStrings.Applications.VideoLanVlcPlayer.UserAgent
                    MaximumRedirection = 0
                    UseBasicParsing    = $True
                    ErrorAction        = "SilentlyContinue"
                }
                $Response = Invoke-WebRequest @iwrParams
                $URI = $Response.Links[0].href
            }

            # Construct the output; Return the custom object to the pipeline
            ForEach ($extension in $script:resourceStrings.Applications.VideoLanVlcPlayer.Extensions.Windows) {
                $PSObject = [PSCustomObject] @{
                    Version      = $Content[0]
                    Platform     = "Windows"
                    Architecture = $platform.Name
                    Type         = $extension
                    URI          = $URI -replace ".exe$", (".$extension").ToLower()
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion
}
