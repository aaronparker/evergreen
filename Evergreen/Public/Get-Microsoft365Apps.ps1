Function Get-Microsoft365Apps {
    <#
        .SYNOPSIS
            Returns the latest Microsoft 365 Apps version number for each channel and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Microsoft365Apps

            Description:
            Returns the latest Microsoft 365 Apps version number and download.
    #>
    [Alias("Get-MicrosoftOffice")]
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # For each Office channel
    ForEach ($channel in $res.Get.Update.Channels.GetEnumerator()) {

        # Get latest version Microsoft Office versions from the Office API
        try {
            $Uri = "$($res.Get.Update.Uri)$($res.Get.Update.Channels[$channel.Key])"
            $updateFeed = Invoke-RestMethodWrapper -Uri $Uri
        }
        catch {
            Throw "Failed to resolve update feed: $Uri."
            Break
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
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a usable object from: $Uri."
        }
    }
}
