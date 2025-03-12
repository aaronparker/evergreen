function Get-MicrosoftVisualStudioCode {
    <#
        .SYNOPSIS
            Reads the Microsoft Visual Studio code update API to retrieve available Stable and Insider builds version numbers and download URLs for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

            Download URLs
            "https://aka.ms/win32-x64-user-stable"
            "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
            "https://vscode-update.azurewebsites.net/latest/win32-x64-user/stable"
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split('-'))[1])
    )

    # Walk through each platform
    foreach ($platform in $res.Get.Update.Platform) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Getting release info for $platform."

        # Walk through each channel in the platform
        foreach ($channel in $res.Get.Update.Channel) {
            # Read the version details from the API, format and return to the pipeline
            $Uri = "$($res.Get.Update.Uri)/$($platform.ToLower())/$($channel.ToLower())/latest"
            $updateFeed = Invoke-EvergreenRestMethod -Uri $Uri
            if ($updateFeed) {
                $PSObject = [PSCustomObject] @{
                    Version      = $updateFeed.productVersion -replace $res.Get.Update.ReplaceText, ''
                    Platform     = $platform
                    Channel      = $channel
                    Architecture = Get-Architecture -String $updateFeed.url
                    Sha256       = $updateFeed.sha256hash
                    URI          = $updateFeed.url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
