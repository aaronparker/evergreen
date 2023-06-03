function Get-ChromiumChromeDriver {
    <#
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
    $UpdateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri.Chrome
    if ($null -ne $UpdateFeed) {

        # Read the JSON and build an array of platform, channel, version
        foreach ($channel in $res.Get.Update.Channels) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Channel: $channel."

            # Step through each platform property
            foreach ($platform in $res.Get.Update.Platforms) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Platform: $platform."

                # Filter the feed for the specific channel and platform
                $UpdateItem = $UpdateFeed.versions | Where-Object { ($_.channel -eq $channel) -and ($_.os -eq $platform) }
                foreach ($item in $UpdateItem) {

                    try {
                        # Query for the matching ChromeDriver version
                        $Version = [System.Version]$item.Version
                        $params = @{
                            Uri          = $res.Get.Update.Uri.Driver -replace "#version", "$($Version.Major).$($Version.Minor).$($Version.Build)"
                            ReturnObject = "Content"
                        }
                        $DriverVersion = Invoke-WebRequestWrapper @params
                    }
                    catch {
                        # If the URL above fails, the version doesn't match Chrome, so try without the version number
                        $params = @{
                            Uri          = $res.Get.Update.Uri.Driver -replace "_#version", ""
                            ReturnObject = "Content"
                        }
                        $DriverVersion = Invoke-WebRequestWrapper @params
                    }

                    if ($null -ne $DriverVersion) {
                        # Output the version and URI object
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($item.Count) item/s for $($channel.Name), $platform."
                        $PSObject = [PSCustomObject] @{
                            Version = $DriverVersion.Trim()
                            Channel = $item.Channel
                            Type    = Get-FileType -File $res.Get.Download.Uri
                            URI     = $res.Get.Download.Uri -replace "#version", $DriverVersion.Trim()
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
