Function Get-GoogleChrome {
    <#
        .SYNOPSIS
            Returns the available Google Chrome versions across all platforms and channels by querying the official Google version JSON.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

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
                    Date         = ConvertTo-DateTime -DateTime $version.current_reldate.Trim() -Pattern $res.Get.Download.DatePattern
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
