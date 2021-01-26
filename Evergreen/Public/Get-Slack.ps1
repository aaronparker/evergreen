Function Get-Slack {    
    <#
        .SYNOPSIS
            Get the current version and download URL for Slack.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Slack

            Description:
            Returns the current version and download URL for Slack.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    ForEach ($platform in $res.Get.Download.Keys) {
        ForEach ($architecture in $res.Get.Download[$platform].Keys) {

            # Follow the download link which will return a 301/302
            $Url = (Resolve-SystemNetWebRequest -Uri $res.Get.Download[$platform][$architecture]).ResponseUri.AbsoluteUri

            # Match version number from the download URL
            try {
                $Version = [RegEx]::Match($Url, $res.Get.MatchVersion).Captures.Groups[0].Value
            }
            catch {
                $Version = "Latest"
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Platform     = $platform
                Architecture = $architecture
                URI          = $Url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
