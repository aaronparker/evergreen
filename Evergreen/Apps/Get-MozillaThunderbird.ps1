function Get-MozillaThunderbird {
    <#
        .SYNOPSIS
            Returns downloads for the latest Mozilla Thunderbird releases.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

            # https://wiki.mozilla.org/Release_Management/Product_details
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNull()]
        [System.String[]] $Language = @("en-US")
    )

    # Get latest Firefox version
    $Versions = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Construct custom object with output details
    foreach ($platform in $res.Get.Download.Platforms) {
        foreach ($channel in $res.Get.Update.Channels.GetEnumerator()) {
            foreach ($currentLanguage in $Language) {

                # Select the download file for the selected platform
                foreach ($installer in $res.Get.Download.Uri[$channel.Key].GetEnumerator()) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Resolve URL for: $($channel.Key)"

                    # Get the version for this channel
                    $RawVersion = $Versions.($channel.Key)
                    $Version = $Versions.($channel.Key) -replace $res.Get.Download.ReplaceText.Version, ""
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Channel: $($channel.Key) - found version: $Version."

                    $params = @{
                        Uri           = (($res.Get.Download.Uri[$channel.Key][$installer.Key] -replace $res.Get.Download.ReplaceText.Platform, $platform) `
                                -replace $res.Get.Download.ReplaceText.Language, $currentLanguage) -replace "#version", $RawVersion
                        ErrorAction   = "SilentlyContinue"
                        WarningAction = "SilentlyContinue"
                    }
                    $Url = Resolve-InvokeWebRequest @params
                    if ($null -ne $Url) {

                        # Build object and output to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $Version
                            Channel      = $channel.Value
                            Language     = $currentLanguage
                            Architecture = Get-Architecture -String $platform
                            Type         = Get-FileType -File $Url
                            Filename     = (Split-Path -Path $Url -Leaf).Replace('%20', ' ')
                            URI          = $Url
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }

            # Remove variables for next iteration
            Remove-Variable -Name "Version" -ErrorAction "SilentlyContinue"
            Remove-Variable -Name "Url" -ErrorAction "SilentlyContinue"
        }
    }
}
