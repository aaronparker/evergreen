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

    # Get the commit details
    $params = @{
        Uri         = $res.Get.Update.Version.Uri
        ErrorAction = "Stop"
    }
    $Commit = (Invoke-EvergreenRestMethod @params).($res.Get.Update.Version.Property)

    # Walk through each platform
    if ([System.String]::IsNullOrEmpty($Commit)) {
        throw "$($MyInvocation.MyCommand): No value found for property: $($res.Get.Update.Version.Property)."
    }
    else {
        foreach ($platform in $res.Get.Update.Platform) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Getting release info for $platform."

            # Walk through each channel in the platform
            foreach ($channel in $res.Get.Update.Channel) {

                # Read the version details from the API, format and return to the pipeline
                $params = @{
                    Uri         = "$($res.Get.Update.Uri)/$($platform.ToLower())/$($channel.ToLower())/$Commit"
                    ErrorAction = "Stop"
                }
                $updateFeed = Invoke-EvergreenRestMethod @params

                if ([System.String]::IsNullOrEmpty($updateFeed)) {
                    throw "$($MyInvocation.MyCommand): No update feed found for $platform and $channel."
                }
                else {
                    $PSObject = [PSCustomObject] @{
                        Version  = $updateFeed.productVersion -replace $res.Get.Update.ReplaceText, ""
                        Platform = $platform
                        Channel  = $channel
                        Sha256   = $updateFeed.sha256hash
                        URI      = $updateFeed.url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
