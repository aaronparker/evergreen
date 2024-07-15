function Get-MozillaFirefox {
    <#
        .SYNOPSIS
            Returns downloads for the latest Mozilla Firefox releases.

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
    foreach ($currentLanguage in $Language) {
        foreach ($channel in $res.Get.Update.Channels.GetEnumerator()) {
            foreach ($platform in $res.Get.Download.Platforms) {

                # Select the download file for the selected platform
                foreach ($installer in $res.Get.Download.Uri[$channel.Key].GetEnumerator()) {

                    $params = @{
                        Uri           = (($res.Get.Download.Uri[$channel.Key][$installer.Key] -replace $res.Get.Download.ReplaceText.Platform, $platform) `
                                -replace $res.Get.Download.ReplaceText.Language, $currentLanguage)
                        ErrorAction   = "SilentlyContinue"
                        WarningAction = "SilentlyContinue"
                    }
                    $Url = Resolve-InvokeWebRequest @params
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
        }
    }
}
