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
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the JSON and convert to a PowerShell object. Return the current release version of Teams
    $Content = Invoke-WebContent -Uri $res.Get.Uri

    # Read the JSON and build an array of platform, channel, version
    If ($Null -ne $Content) {

        # Convert object from JSON
        $Json = $Content | ConvertFrom-Json

        # Match version number
        $Json.releasesPath -match $res.Get.MatchVersion | Out-Null
        $Version = $Matches[1]

        # Step through each architecture
        ForEach ($item in $res.Get.DownloadUri.GetEnumerator()) {

            # Build the output object
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $item.Name
                URI          = $res.Get.DownloadUri[$item.Key] -replace "#Version", $Version
            }

            # Output object to the pipeline
            Write-Output -InputObject $PSObject
        }
    }

    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Uri)."
    }
}
