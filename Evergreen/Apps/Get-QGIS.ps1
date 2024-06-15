function Get-QGIS {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name ends in s")]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the update feed
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Return an object for each channel
    foreach ($Channel in $res.Get.Update.Channels) {
        $Version = "$($UpdateFeed.$Channel.version)-$($UpdateFeed.$Channel.binary)"
        [PSCustomObject]@{
            Version = $Version
            Channel = $Channel
            Date    = $UpdateFeed.$Channel.date
            URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $Version
        } | Write-Output
    }
}