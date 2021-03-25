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
            Returns the current version and download URLs for VLC Media Player on Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Get current version for Windows
    ForEach ($platform in $res.Get.Update.Uri.Windows.GetEnumerator()) {
        $params = @{
            Uri         = $res.Get.Update.Uri.Windows[$platform.Key]
            ContentType = "application/octet-stream"
        }
        $Content = Invoke-RestMethodWrapper @params

        If ($Null -ne $Content) {
            # Follow the download link which will return a 301
            $params = @{
                Uri       = ($Content -split "\n")[$res.Get.Download.UrlLine]
                UserAgent = $res.Get.Update.UserAgent
            }
            $redirectUrl = Resolve-InvokeWebRequest @params

            # Construct the output; Return the custom object to the pipeline
            ForEach ($extension in $res.Get.Download.Extensions.Windows) {
                $PSObject = [PSCustomObject] @{
                    Version      = ($Content -split "\n")[$res.Get.Download.VersionLine]
                    Platform     = "Windows"
                    Architecture = $platform.Name
                    Type         = $extension
                    URI          = $redirectUrl -replace ".exe$", (".$extension").ToLower()
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion
}
