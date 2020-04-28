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
    ForEach ($platform in $res.Get.Uri.Windows.GetEnumerator()) {
        $Content = Invoke-WebContent -Uri $res.Get.Uri.Windows[$platform.Key] -Raw

        If ($Null -ne $Content) {
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
    }
    #endregion
}
