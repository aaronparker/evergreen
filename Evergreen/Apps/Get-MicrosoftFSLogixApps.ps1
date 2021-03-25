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
    $response = Resolve-SystemNetWebRequest -Uri $res.Get.Uri
            
    # Check returned URL. It should be a go.microsoft.com/fwlink/?linkid style link
    If ($Null -ne $response) {

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($($response.ResponseUri.AbsoluteUri), $res.Get.MatchVersion).Captures.Value
            Date    = ConvertTo-DateTime -DateTime $response.LastModified
            URI     = $response.ResponseUri.AbsoluteUri
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "Failed to return a useable URL from $($res.Get.Uri)."
    }
}
