Function Get-MicrosoftTeams {
    <#
        .SYNOPSIS
            Returns the available Microsoft Teams versions and download URIs.

        .DESCRIPTION
            Returns the available Microsoft Teams versions and download URIs for Windows.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftTeams

            Description:
            Returns the available Microsoft Teams versions and download URIs for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the JSON and convert to a PowerShell object. Return the current release version of Teams
    $Content = Invoke-WebContent -Uri $res.Get.Update.Uri

    # Read the JSON and build an array of platform, channel, version
    If ($Null -ne $Content) {

        # Convert object from JSON
        $Json = $Content | ConvertFrom-Json

        # Match version number
        $Version = [RegEx]::Match($Json.releasesPath, $res.Get.Update.MatchVersion).Captures.Groups[1].Value

        # Step through each architecture
        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

            # Build the output object
            $PSObject = [PSCustomObject] @{
                Version      = $Version
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
