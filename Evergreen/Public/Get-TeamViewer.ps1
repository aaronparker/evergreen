Function Get-TeamViewer {
    <#
        .SYNOPSIS
            Get the current version and download URL for TeamViewer.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-TeamViewer

            Description:
            Returns the current version and download URI for TeamViewer on Windows (x86, x64) and macOS.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get the latest TeamViewer version
    $Content = Invoke-SystemNetRequest -Uri $res.Get.Uri

    # Construct the output; Return the custom object to the pipeline
    If ($Null -ne $Content) {
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Content, $res.Get.MatchVersion).Captures.Groups[1].Value
            URI     = $res.Get.DownloadUri
        }
        Write-Output -InputObject $PSObject
    }
}
