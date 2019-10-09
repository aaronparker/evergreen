Function Get-CitrixApplicationDeliveryManagementFeed {
    <#
        .SYNOPSIS
            Gets the current available Citrix Application Delivery Management downloads.

        .DESCRIPTION
            Reads the public Citrix Application Delivery Management web page to return an array of platforms and the available versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-CitrixApplicationDeliveryManagementFeed

            Description:
            Returns the available Citrix Application Delivery Management downloads.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $script:resourceStrings.Applications.CitrixFeeds.ApplicationDeliveryManagement.Uri
        Include = $script:resourceStrings.Applications.CitrixFeeds.ApplicationDeliveryManagement.Include
        Exclude = $script:resourceStrings.Applications.CitrixFeeds.ApplicationDeliveryManagement.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
