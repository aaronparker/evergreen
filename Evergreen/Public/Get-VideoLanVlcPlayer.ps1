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

        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
        }

        # Build an output object by selecting installer entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {

            # Select the required node/s from the XML feed
            $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"

            # Find the latest version
            $latest = $nodes | Sort-Object -Property "title" -Descending | Select-Object -First 1
            $version = $latest.title.Trim($res.Get.TrimVersion)

            # Follow the download link which will return a 301
            $rruParams = @{
                Uri       = $($res.Get.DownloadUriMacOS -replace "#version", $version)
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
