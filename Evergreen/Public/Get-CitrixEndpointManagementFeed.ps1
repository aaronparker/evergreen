Function Get-CitrixEndpointManagementFeed {
    <#
        .SYNOPSIS
            Gets the current available Citrix Endpoint Management downloads.

        .DESCRIPTION
            Reads the public Citrix Endpoint Management web page to return an array of platforms and the available versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-CitrixEndpointManagementFeed

            Description:
            Returns the available Citrix Endpoint Management downloads.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName "CitrixFeeds"
    Write-Verbose -Message $res.Name

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $res.Get.EndpointManagement.Uri
        Include = $res.Get.EndpointManagement.Include
        Exclude = $res.Get.EndpointManagement.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
