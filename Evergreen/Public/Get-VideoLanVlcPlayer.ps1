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
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.VideoLanVlcPlayer.UriMac
    $xml = [System.XML.XMLDocument] $Content
    $latest = $xml.rss.channel.item[$xml.rss.channel.item.Length - 1]
    $version = $latest.title.Trim("Version ")
    $PSObject = [PSCustomObject] @{
        Version  = $version
        Platform = "macOS"
        URI      = "https://get.videolan.org/vlc/$version/macosx/vlc-$version.dmg"
    }
    Write-Output -InputObject $PSObject
    #endregion

    #region Get current version for Windows
    ForEach ($platform in @("UriWin64", "UriWin32")) {
        $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.VideoLanVlcPlayer.$platform -Raw

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version  = $Content[0]
            Platform = $platform.Replace("Uri", "")
            URI      = $Content[1]
        }
        Write-Output -InputObject $PSObject
    }
    #endregion
}
