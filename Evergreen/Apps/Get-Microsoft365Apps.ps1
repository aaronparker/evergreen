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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # For each Office channel
    ForEach ($channel in $res.Get.Update.Channels.GetEnumerator()) {

        # Get latest version Microsoft Office versions from the Office API
        try {
            $Uri = "$($res.Get.Update.Uri)$($res.Get.Update.Channels[$channel.Key])"
            $updateFeed = Invoke-RestMethodWrapper -Uri $Uri
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to resolve update feed: $Uri."
        }

        If ($Null -ne $updateFeed) {
            
            # Build and array of the latest release and download URLs
            $PSObject = [PSCustomObject] @{
                Version = $updateFeed.AvailableBuild
                Date    = ConvertTo-DateTime -DateTime $updateFeed.TimestampUtc -Pattern $res.Get.Update.DateTime
                Channel = $channel.Name
                URI     = $res.Get.Download.Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
