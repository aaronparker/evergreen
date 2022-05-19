Function Get-CitrixWorkspaceAppFeed {
    <#
        .SYNOPSIS
            Reads the public Citrix Workspace app feed to return an array of versions and links to download pages.

            Does not provide the version number for Receiver where a login is required (e.g. HTML5, Chrome).

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
    $params = @{
        Uri     = $res.Get.WorkspaceApp.Uri
        Include = $res.Get.WorkspaceApp.Include
        Exclude = $res.Get.WorkspaceApp.Exclude
    }
    $Content = Get-CitrixRssFeed @params
    Write-Output -InputObject $Content
}
