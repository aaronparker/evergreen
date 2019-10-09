Function Get-CitrixApplicationDeliveryManagementFeed {
    <#
        .SYNOPSIS
            Gets the current available Citrix Application Delivery Management downloads.

        .DESCRIPTION
            Reads the public Citrix Receiver web page to return an array of Receiver platforms and the available versions.
            Does not provide the version number for Receiver where a login is required (e.g. HTML5, Chrome)

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-CitrixApplicationDeliveryManagementFeed

            Description:
            Returns the available Citrix Application Delivery Management downloads.
    #>
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
