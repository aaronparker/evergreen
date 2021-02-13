Function Get-CitrixWorkspaceAppFeed {
    <#
        .SYNOPSIS
            Reads the public Citrix Workspace app feed to return an array of versions and links to download pages.    

            Does not provide the version number for Receiver where a login is required (e.g. HTML5, Chrome).

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-CitrixWorkspaceAppFeed

            Description:
            Returns the available Citrix Workspace app versions for all platforms.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName "CitrixFeeds"
    Write-Verbose -Message $res.Name

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $params = @{
        Uri     = $res.Get.WorkspaceApp.Uri
        Include = $res.Get.WorkspaceApp.Include
        Exclude = $res.Get.WorkspaceApp.Exclude
    }
    $Content = Get-CitrixRssFeed @params
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
