Function Get-MicrosoftFSLogixApps {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft FSLogix Apps agent.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftFSLogixApps

            Description:
            Returns the current version and download URL for the Microsoft FSLogix Apps agent.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Follow the download link which will return a 301
    $redirectUrl = Resolve-RedirectedUri -Uri $res.Get.Uri
            
    # Check returned URL. It should be a go.microsoft.com/fwlink/?linkid style link
    If ($redirectUrl -match $res.Get.MatchFwlink) {
        $nextRedirectUrl = Resolve-RedirectedUri -Uri $redirectUrl

        # If this returned URL target is a file
        If ($nextRedirectUrl -match $res.Get.MatchFile) {

            # Grab the version number from the link
            $nextRedirectUrl -match $res.Get.MatchVersion | Out-Null

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $matches[0]
                URI     = $nextRedirectUrl
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "Failed to return a useable URL from $redirectUrl."
        }
    }
    Else {
        Write-Warning -Message "Failed to return a useable URL from $($res.Get.Uri)."
    }
}
