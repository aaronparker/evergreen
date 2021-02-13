Function Get-MozillaThunderbird {
    <#
        .SYNOPSIS
            Returns downloads for the latest Mozilla Thunderbird releases.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Evergreen/

        .PARAMETER Language
            Specify the Thunderbird language version to return.

        .EXAMPLE
            Get-MozillaThunderbird

            Description:
            Returns the version and download URIs for Thunderbird for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest Thunderbird version
    $thunderbirdVersions = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    
    # Construct custom object with output details
    ForEach ($language in $res.Get.Download.Languages) {
        ForEach ($channel in $res.Get.Update.Channels) {
            ForEach ($platform in $res.Get.Download.Platforms) {

                # Select the download file for the selected platform
                ForEach ($installer in $res.Get.Download.Uri[$channel].GetEnumerator()) {
                    $params = @{
                        Uri = (($res.Get.Download.Uri[$channel][$installer.Key] -replace $res.Get.Download.Text.Platform, $platform) -replace $res.Get.Download.Text.Language, $language)
                    }
                    $response = Resolve-SystemNetWebRequest @params

                    # Build object and output to the pipeline
                    $PSObject = [PSCustomObject] @{
                        Version      = $thunderbirdVersions.$channel
                        Architecture = Get-Architecture -String $platform
                        Channel      = $channel
                        Language     = $language
                        Type         = [System.IO.Path]::GetExtension($response.ResponseUri.AbsoluteUri).Split(".")[-1]
                        Filename     = (Split-Path -Path $response.ResponseUri.AbsoluteUri -Leaf).Replace('%20', ' ')
                        URI          = $response.ResponseUri.AbsoluteUri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
