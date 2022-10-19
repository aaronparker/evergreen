Function Get-Microsoft365Apps {
    <#
        .SYNOPSIS
            Returns the latest Microsoft 365 Apps version number for each channel and download.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Updates = Invoke-RestMethodWrapper @params

    ForEach ($Update in $Updates) {

        # Find the release date for this version
        $Date = ($Update.officeVersions | Where-Object { $_.legacyVersion -eq $Update.latestVersion }).availabilityDate

        # Build and array of the latest release and download URLs
        $PSObject = [PSCustomObject] @{
            Version = $Update.latestVersion
            Channel = $Update.channelId
            Name    = $res.Get.Update.ChannelNames.$($Update.channelId)
            Date    = [System.DateTime]$Date
            URI     = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
