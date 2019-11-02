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

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName "CitrixFeeds"
    Write-Verbose -Message $res.Name

    # Read the feed and filter for include and exclude strings and return output to the pipeline
    $gcfParams = @{
        Uri     = $res.Get.Licensing.Uri
        Include = $res.Get.Licensing.Include
        Exclude = $res.Get.Licensing.Exclude
    }
    $Content = Get-CitrixRssFeed @gcfParams
    If ($Null -ne $Content) {
        Write-Output -InputObject $Content
    }
}
