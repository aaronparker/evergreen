Function Get-MicrosoftAzureDataStudio {
    <#
        .SYNOPSIS
            Reads the Microsoft Azure Data Studio code update API to retrieve available Stable and Insider builds version numbers and download URLs for Windows.

        .NOTES
            Site: https://stealthpuppy.com
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

    # Get the commit details
    $commit = (Invoke-RestMethodWrapper -Uri $res.Get.Update.Version.Uri).($res.Get.Update.Version.Property)

    # Walk through each platform
    If ($commit) {
        ForEach ($platform in $res.Get.Update.Platform) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Getting release info for $platform."

            # Walk through each channel in the platform
            ForEach ($channel in $res.Get.Update.Channel) {

                # Read the version details from the API, format and return to the pipeline
                $Uri = "$($res.Get.Update.Uri)/$($platform.ToLower())/$($channel.ToLower())/$commit"
                $updateFeed = Invoke-RestMethodWrapper -Uri $Uri
                If ($updateFeed) {
                    $PSObject = [PSCustomObject] @{
                        Version      = $updateFeed.productVersion -replace $res.Get.Update.ReplaceText, ""
                        Platform     = $platform
                        Channel      = $channel
                        Sha256       = $updateFeed.sha256hash
                        URI          = $updateFeed.url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): failed to get commit details from: $($res.Get.Update.Version.Uri)."
    }
}
