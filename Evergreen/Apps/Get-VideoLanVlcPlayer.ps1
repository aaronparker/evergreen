Function Get-VideoLanVlcPlayer {
    <#
        .SYNOPSIS
            Get the current version and download URL for VideoLAN VLC Media Player.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

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
