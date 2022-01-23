Function Get-Slack {
    <#
        .SYNOPSIS
            Get the current version and download URL for Slack.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    ForEach ($platform in $res.Get.Download.Keys) {
        ForEach ($architecture in $res.Get.Download[$platform].Keys) {

            # Follow the download link which will return a 301/302
            $redirectUrl = Resolve-SystemNetWebRequest -Uri $res.Get.Download[$platform][$architecture]

            # Match version number from the download URL
            try {
                $Version = [RegEx]::Match($redirectUrl.ResponseUri.AbsoluteUri, $res.Get.MatchVersion).Captures.Groups[0].Value
            }
            catch {
                $Version = "Latest"
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Platform     = $platform
                Architecture = $architecture
                URI          = $redirectUrl.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
