function Get-MicrosoftAzureDataStudio {
    <#
        .SYNOPSIS
            Reads the Microsoft Azure Data Studio code update API to retrieve available
            Stable and Insider builds version numbers and download URLs for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($platform in $res.Get.Update.Platform) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Getting release info for $platform."

        # Walk through each channel in the platform
        foreach ($channel in $res.Get.Update.Channel) {

            # Resolve details for the update feed
            $params = @{
                Uri         = $res.Get.Update.Uri -replace "#platform", $platform.ToLower() -replace "#channel", $channel.ToLower()
                ErrorAction = "Stop"
            }
            $UpdateFeed = Invoke-EvergreenRestMethod @params

            # If we have a valid response, output the details
            if ($null -ne $UpdateFeed) {
                $Url = $(Resolve-SystemNetWebRequest -Uri $UpdateFeed.url).ResponseUri.AbsoluteUri
                $PSObject = [PSCustomObject] @{
                    Version      = $UpdateFeed.productVersion
                    Channel      = $channel
                    Platform     = $platform
                    Sha256       = $UpdateFeed.sha256hash
                    Type         = Get-FileType -File $Url
                    URI          = $Url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
