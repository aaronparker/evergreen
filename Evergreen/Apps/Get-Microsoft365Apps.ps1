Function Get-Microsoft365Apps {
    <#
        .SYNOPSIS
            Returns the latest Microsoft 365 Apps version number for each channel and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # For each Office channel
    ForEach ($channel in $res.Get.Update.Channels.GetEnumerator()) {

        # Get latest version Microsoft Office versions from the Office API
        Write-Verbose -Message "$($MyInvocation.MyCommand): Select channel: $($res.Get.Update.Channels[$channel.Key])."
        $params = @{
            Uri = "$($res.Get.Update.Uri)$($res.Get.Update.Channels[$channel.Key])"
        }
        $updateFeed = Invoke-RestMethodWrapper @params
        If ($Null -ne $updateFeed) {

            # If LkgBuild less than AvailableBuild, then it's the current version
            If ([System.Version]$updateFeed.LkgBuild -lt [System.Version]$updateFeed.AvailableBuild) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Fallback to LkgBuild version: $($updateFeed.LkgBuild)."
                $Version = $updateFeed.LkgBuild
            }
            Else {
                $Version = $updateFeed.AvailableBuild
            }

            # Build and array of the latest release and download URLs
            $PSObject = [PSCustomObject] @{
                Version    = $Version
                Channel    = $channel.Name
                Name       = $res.Get.Update.ChannelNames.$($channel.Name)
                Date       = ConvertTo-DateTime -DateTime $updateFeed.TimestampUtc -Pattern $res.Get.Update.DateTime
                URI        = $res.Get.Download.Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
