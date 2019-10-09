Function Get-CitrixLicensingFeed {
    <#
        .SYNOPSIS
            Gets the current available Citrix Licensing Server release versions.

        .DESCRIPTION
            Reads the public Citrix Licensing web page to return an array of Licensing platforms and the available versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .EXAMPLE
            Get-CitrixLicensingFeed

            Description:
            Returns the available Citrix Licensing versions for all platforms.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $script:resourceStrings.Applications.CitrixFeeds.Licensing.Uri
        Include = $script:resourceStrings.Applications.CitrixFeeds.Licensing.Include
        Exclude = $script:resourceStrings.Applications.CitrixFeeds.Licensing.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
