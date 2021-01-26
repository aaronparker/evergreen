Function Get-MicrosoftVisualStudio {
    <#
        .SYNOPSIS
            Returns the current version of Microsoft Visual Studio and the download URL for Microsoft Visual Studio boot strapper.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftVisualStudio

            Description:
            Returns the current version of Microsoft Visual Studio and the download URL for Microsoft Visual Studio boot strapper.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Resolve the update feed from the initial URI
    $ResolvedUrl = (Resolve-SystemNetWebRequest -Uri $res.Get.Update.Uri).ResponseUri.AbsoluteUri

    If ($ResolvedUrl) {
        try {
            # Get details from the update feed
            $updateFeed = Invoke-RestMethodWrapper -Uri $ResolvedUrl
        }
        catch {
            Throw "Failed to resolve update feed: $ResolvedUrl."
            Break
        }
        finally {
            # Build the output object/s
            $items = $updateFeed.channelItems | Where-Object { $_.id -eq $res.Get.Update.MatchFilter }
            ForEach ($item in $items) { 
                $PSObject = [PSCustomObject] @{
                    Version = $updateFeed.info.buildVersion
                    Sha256  = $item.payloads[0].Sha256
                    Size    = $item.payloads[0].size
                    URI     = $item.payloads[0].url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to resolve the update API: $($res.Get.Update.Uri)."
    }
}
