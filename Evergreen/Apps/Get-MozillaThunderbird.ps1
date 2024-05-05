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
                    try {
                        $params = @{
                            Uri = (($res.Get.Download.Uri[$channel.Key][$installer.Key] -replace $res.Get.Download.ReplaceText.Platform, $platform) `
                                    -replace $res.Get.Download.ReplaceText.Language, $currentLanguage)
                        }
                        $Url = Resolve-InvokeWebRequest @params
                    }
                    catch {
                        Write-Error -Message "$($MyInvocation.MyCommand): Failed to resolve $Url, with: $($_.Exception.Message)"
                        continue
                    }
                    if ($null -ne $Url) {

                        # Catch if version is null
                        if ([System.String]::IsNullOrEmpty($Versions.$($channel.Key))) {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): No version info for channel: $($channel.Key)."
                            $Version = "Unknown"
                        }
                        else {
                            $Version = $Versions.$($channel.Key) -replace $res.Get.Download.ReplaceText.Version, ""
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."
                        }

                        # Build object and output to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $Version
                            Architecture = Get-Architecture -String $platform
                            Channel      = $channel.Value
                            Language     = $currentLanguage
                            Type         = Get-FileType -File $Url
                            Filename     = (Split-Path -Path $Url -Leaf).Replace('%20', ' ')
                            URI          = $Url
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }

            # Build an MSIX object and output to the pipeline
            if ((Get-Architecture -String $platform) -eq "x64") {
                $Url = $res.Get.Download.Msix -replace $res.Get.Download.ReplaceText.Platform, $platform `
                    -replace "#version", $Version

                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Architecture = "x64"
                    Channel      = $channel.Value
                    Language     = "Multi"
                    Type         = Get-FileType -File $Url
                    Filename     = (Split-Path -Path $Url -Leaf).Replace('%20', ' ')
                    URI          = $Url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
