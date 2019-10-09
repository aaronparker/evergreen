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

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $script:resourceStrings.Applications.CitrixFeeds.EndpointManagement.Uri
        Include = $script:resourceStrings.Applications.CitrixFeeds.EndpointManagement.Include
        Exclude = $script:resourceStrings.Applications.CitrixFeeds.EndpointManagement.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
