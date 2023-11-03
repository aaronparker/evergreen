function Get-MicrosoftVisualStudio {
    <#
        .SYNOPSIS
            Returns the current version of Microsoft Visual Studio and the download URL for Microsoft Visual Studio boot strapper.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get details from the update feed
    $updateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Build the output object/s
    $items = $updateFeed.channelItems | Where-Object { $_.id -eq $res.Get.Update.MatchFilter }
    foreach ($item in $items) {
        $PSObject = [PSCustomObject] @{
            Version = $updateFeed.info.buildVersion
            Sha256  = $item.payloads[0].Sha256
            Size    = $item.payloads[0].size
            URI     = $item.payloads[0].url
        }
        Write-Output -InputObject $PSObject
    }
}
