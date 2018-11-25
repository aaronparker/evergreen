Function Get-VlcPlayerUpdateWin {
    <#
        .SYNOPSIS
            Queries the VLC Player for Windows update site and returns the version number and download URL.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('Win32', 'Win64')]
        [string] $Platform = 'Win64'
    )

    # Platform URLs
    $platforms = [PSCustomObject]@{
        Win32 = 'https://update.videolan.org/vlc/status-win-x86'
        Win64 = 'https://update.videolan.org/vlc/status-win-x64'
    }

    # RegEx to match version numbers
    # $versionRegEx = "\d+\.\d+\.\d+"

    # Query the VLC Player update site
    $r = Invoke-WebRequest -Uri $platforms.$Platform
    $lines = $r.RawContent -Split "`n"

    # Construct the output
    $output = [PSCustomObject]@{
        Platform = $Platform
        Version  = $lines[11]
        URI      = $lines[12]
    }

    # Return the custom object to the pipeline
    Write-Output $output
}
