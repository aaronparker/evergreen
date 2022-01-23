Function Get-CitrixReceiverFeed {
    <#
        .SYNOPSIS
            Reads the public Citrix Receiver feed to return an array of versions and links to download pages.

        .NOTES
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

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $res.Get.Receiver.Uri
        Include = $res.Get.Receiver.Include
        Exclude = $res.Get.Receiver.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    Write-Output -InputObject $Content
}
