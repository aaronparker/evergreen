Function Get-VlcPlayerUpdateMac {
    <#
        .SYNOPSIS
            Queries the VLC Player for Windows update site and returns the version number and download URL.
    #>
    [CmdletBinding()]
    Param()

    # RegEx to match version numbers
    # $versionRegEx = "\d+\.\d+\.\d+"

    # Query the VLC Player update site
    $r = Invoke-WebRequest -Uri "http://update.videolan.org/vlc/sparkle/vlc-intel64.xml"
    $xml = [xml] $r.Content
    $latest = $xml.rss.channel.item[$xml.rss.channel.item.Length - 1]
    $version = $latest.title.Trim("Version ")
    
    # Construct the output
    $output = [PSCustomObject]@{
        Platform = "macOS"
        Version  = $version
        URI      = "https://get.videolan.org/vlc/$version/macosx/vlc-$version.dmg"
    }

    # Return the custom object to the pipeline
    Write-Output $output
}
