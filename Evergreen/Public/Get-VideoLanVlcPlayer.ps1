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

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Get current version for macOS
    $Content = Invoke-WebContent -Uri $res.Get.Uri.macOS
    If ($Null -ne $Content) {
        try {
            $xml = [System.XML.XMLDocument] $Content
            $latest = $xml.rss.channel.item | Select-Object -Last 1
            $version = $latest.title.Trim("Version ")
        }
        catch {
            Write-Verbose -Message "Error reading the update URL and converting to XML."
        }

        # Follow the download link which will return a 301
        $rruParams = @{
            Uri       = "https://get.videolan.org/vlc/$version/macosx/vlc-$version.dmg"
            UserAgent = $res.Get.UserAgent
        }
        $redirectUrl = Resolve-RedirectedUri @rruParams

        # Construct the output; Return the custom object to the pipeline
        ForEach ($extension in $res.Get.Extensions.macOS) {
            $PSObject = [PSCustomObject] @{
                Version      = $version
                Platform     = "macOS"
                Architecture = "x64"
                Type         = $extension
                URI          = $redirectUrl
            }
            Write-Output -InputObject $PSObject
        }
    }
    #endregion

    #region Get current version for Windows
    ForEach ($platform in $res.Get.Uri.Windows.GetEnumerator()) {
        $Content = Invoke-WebContent -Uri $res.Get.Uri.Windows[$platform.Key] -Raw

        # Follow the download link which will return a 301
        $rruParams = @{
            Uri       = $Content[1]
            UserAgent = $res.Get.UserAgent
        }
        $redirectUrl = Resolve-RedirectedUri @rruParams

        # Construct the output; Return the custom object to the pipeline
        ForEach ($extension in $res.Get.Extensions.Windows) {
            $PSObject = [PSCustomObject] @{
                Version      = $Content[0]
                Platform     = "Windows"
                Architecture = $platform.Name
                Type         = $extension
                URI          = $redirectUrl -replace ".exe$", (".$extension").ToLower()
            }
            Write-Output -InputObject $PSObject
        }
    }
    #endregion
}
