Function Get-AtlassianBitbucket {
    <#
        .SYNOPSIS
            Returns the available Atlassian Bitbucket versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftTeams

            Description:
            Returns the available Atlassian Bitbucket versions and download URIs for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the update URI
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-RestMethodWrapper @params

    # Read the JSON and build an array of platform, channel, version
    If ($Null -ne $Content) {

        # Match version number
        try {
            $Lines = $Content -split "\n"
            $Version = [RegEx]::Match($Lines[0], $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            $Version = "Unknown"
        }

        # Step through each installer type
        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

            # Build the output object
            $PSObject = [PSCustomObject] @{
                Version = $Version
                Type    = $item.Name
                URI     = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $Version
            }

            # Output object to the pipeline
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Update.Uri)."
    }
}
