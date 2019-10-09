Function Get-CitrixAppLayeringFeed {
    <#
        .SYNOPSIS
            Gets the current available Citrix App Layering release versions.

        .DESCRIPTION
            Reads the public Citrix App Layering web page to return an array of App Layering platforms and the available versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-CitrixAppLayeringFeed

            Description:
            Returns the available Citrix App Layering versions for all platforms.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $script:resourceStrings.Applications.CitrixFeeds.AppLayering.Uri
        Include = $script:resourceStrings.Applications.CitrixFeeds.AppLayering.Include
        Exclude = $script:resourceStrings.Applications.CitrixFeeds.AppLayering.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
