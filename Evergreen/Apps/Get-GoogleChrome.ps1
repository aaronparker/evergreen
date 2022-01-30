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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
    $UpdateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    If ($Null -ne $UpdateFeed) {

        # Read the JSON and build an array of platform, channel, version
        ForEach ($channel in $res.Get.Download.Uri.GetEnumerator()) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Channel: $($channel.Name)."

            # Step through each platform property
            ForEach ($platform in $res.Get.Download.Platforms) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Platform: $platform."

                # Filter the feed for the specific channel and platform
                $UpdateItem = $UpdateFeed.versions | Where-Object { ($_.channel -eq $channel.Name) -and ($_.os -eq $platform) }
                ForEach ($item in $UpdateItem) {

                    # Output the version and URI object
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($item.Count) item/s for $($channel.Name), $platform."
                    $PSObject = [PSCustomObject] @{
                        Version      = $item.Version
                        Architecture = Get-Architecture -String $item.Os
                        Channel      = $item.Channel
                        Date         = ConvertTo-DateTime -DateTime $item.Current_RelDate.Trim() -Pattern $res.Get.Download.DatePattern
                        Type         = [System.IO.Path]::GetExtension($($res.Get.Download.Uri[$channel.Key].($Platform))).Split(".")[-1]
                        URI          = $($res.Get.Download.Uri[$channel.Key].($Platform))
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
