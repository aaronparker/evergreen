Function Get-MicrosoftTeams {
    <#
        .SYNOPSIS
            Returns the available Microsoft Teams versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftTeams

            Description:
            Returns the available Microsoft Teams versions and download URIs.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    ForEach ($ring in $res.Get.Update.Rings.GetEnumerator()) {

        # Read the JSON and convert to a PowerShell object. Return the release version of Teams
        $Uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $res.Get.Update.Rings[$ring.Key]
        $updateFeed = Invoke-RestMethodWrapper -Uri $Uri

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $updateFeed) {

            # Match version number
            $Version = [RegEx]::Match($updateFeed.releasesPath, $res.Get.Update.MatchVersion).Captures.Groups[1].Value

            # Step through each architecture
            ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Ring         = $ring.Name
                    Architecture = $item.Name
                    URI          = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $Version
                }

                # Output object to the pipeline
                Write-Output -InputObject $PSObject
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Update.Uri)."
        }
    }
}
