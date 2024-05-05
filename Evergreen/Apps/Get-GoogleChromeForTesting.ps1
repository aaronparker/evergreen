function Get-GoogleChromeForTesting {
    <#
        .SYNOPSIS
            Returns the available Google Chrome for Testing versions across all platforms and
            channels by querying the official Google version JSON.

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
    $DownloadFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Download.Uri
    if ($null -ne $DownloadFeed) {

        # Get the list of channels in the feed
        $Channels = $DownloadFeed.channels | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name"

        # Read the JSON and build an array of platform, channel, version
        foreach ($channel in $Channels) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Channel: $channel."

            # Step through each platform/architecture we want
            foreach ($platform in $res.Get.Download.Platforms) {

                # Grab the URL for this channel and platform/architecture
                $Url = $DownloadFeed.channels.$channel.downloads.chrome | `
                    Where-Object { $_.platform -eq $platform } | Select-Object -ExpandProperty "url"

                if ($null -ne $Url) {
                    # Output the version and URI object
                    $PSObject = [PSCustomObject] @{
                        Version      = $DownloadFeed.channels.$channel.version
                        Revision     = $DownloadFeed.channels.$channel.revision
                        Channel      = $channel
                        Architecture = Get-Architecture -String $Url
                        Type         = Get-FileType -File $Url
                        URI          = $Url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
