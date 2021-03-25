Function Get-GoogleChrome {
    <#
        .SYNOPSIS
            Returns the available Google Chrome versions across all platforms and channels by querying the offical Google version JSON.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-GoogleChrome

            Description:
            Returns the available Google Chrome versions and download URLs.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    If ($Null -ne $updateFeed) {

        # Read the JSON and build an array of platform, channel, version
        ForEach ($platform in $res.Get.Download.Platforms.GetEnumerator()) {
            
            Write-Verbose -Message "$($MyInvocation.MyCommand): $($platform.Name)."
            $stable = $updateFeed.versions | Where-Object { ($_.channel -eq $res.Get.Download.Channel) -and ($_.os -eq $platform.Name) }

            ForEach ($version in $stable) {
                $PSObject = [PSCustomObject] @{
                    Version      = $version.current_version
                    Architecture = Get-Architecture -String $version.os
                    Date         = ConvertTo-DateTime -DateTime $version.current_reldate.Trim()
                    URI          = "$($res.Get.Download.Uri)$($res.Get.Download.Platforms[$platform.Key])"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Update.Uri)."
    }
}
