Function Get-VideoLanVlcPlayer {
    <#
        .SYNOPSIS
            Get the current version and download URL for VideoLAN VLC Media Player.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-VideoLanVlcPlayer

            Description:
            Returns the current version and download URLs for VLC Media Player on Windows (x86, x64) and macOS.
    #>
    [CmdletBinding()]
    Param()

    # Get VLC Player versions and URLs from private functions
    $Win32 = Get-VlcPlayerUpdateWin -Platform Win32
    $Win64 = Get-VlcPlayerUpdateWin -Platform Win64
    $macOS = Get-VlcPlayerUpdateMac
    
    # Return output object to the pipeline
    Write-Output $Win32, $Win64, $macOS
}
