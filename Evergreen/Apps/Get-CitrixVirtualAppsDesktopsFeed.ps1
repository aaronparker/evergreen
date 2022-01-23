Function Get-CitrixVirtualAppsDesktopsFeed {
    <#
        .SYNOPSIS
            Reads the public Citrix Virtual Apps and Desktops feed to return an array of versions and links to download pages.

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
        Uri     = $res.Get.VirtualAppsDesktops.Uri
        Include = $res.Get.VirtualAppsDesktops.Include
        Exclude = $res.Get.VirtualAppsDesktops.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    Write-Output -InputObject $Content
}
