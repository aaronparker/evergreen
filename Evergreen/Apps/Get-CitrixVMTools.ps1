Function Get-CitrixVMTools {
    <#
        .SYNOPSIS
            Returns the current version and download URL for the Citrix VM Tools.

            Returns both the latest v7 and v9 tools - v7 tools are required for Windows 7 / 2008 R2 etc. Windows 8 and above use v9 tools.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-CitrixVMTools

            Description:
            Returns the current version and download URLs for the Citrix VM Tools.
    #>
    [Alias("Get-CitrixXenServerTools")]
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get details for each update URI
    ForEach ($update in $res.Get.Update.Uri.GetEnumerator()) {
        
        # Get content
        $params = @{
            Uri         = $res.Get.Update.Uri[$update.Key]
            ContentType = $res.Get.Update.ContentType
        }
        $updateFeed = Invoke-RestMethodWrapper @params
    
        # Convert the JSON to usable output
        ForEach ($architecture in $res.Get.Update.Architectures) {
            $PSObject = [PSCustomObject] @{
                Version      = $updateFeed.version
                Architecture = $architecture
                Size         = $updateFeed.$architecture.size
                Checksum     = $updateFeed.$architecture.checksum
                URI          = $updateFeed.$architecture.url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
