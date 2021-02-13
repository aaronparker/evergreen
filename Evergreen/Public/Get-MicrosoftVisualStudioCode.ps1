Function Get-MicrosoftVisualStudioCode {
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

        .LINK
            https://github.com/aaronparker/Evergreen/

        .EXAMPLE
            Get-MicrosoftVisualStudioCode

            Description:
            Returns the Stable and Insider builds version numbers and download URLs for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Walk through each platform
    ForEach ($platform in $res.Get.Update.Platform) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Getting release info for $platform."

        # Walk through each channel in the platform
        ForEach ($channel in $res.Get.Update.Channel) {

            # Read the version details from the API, format and return to the pipeline
            $Uri = "$($res.Get.Update.Uri)/$($platform.ToLower())/$($channel.ToLower())/VERSION"
            $updateFeed = Invoke-RestMethodWrapper -Uri $Uri
            $PSObject = [PSCustomObject] @{
                Version      = $updateFeed.productVersion -replace $res.Get.Update.ReplaceText, ""
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
