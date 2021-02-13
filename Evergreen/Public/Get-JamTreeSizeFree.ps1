Function Get-JamTreeSizeFree {
    <#
        .SYNOPSIS
            Returns the the latest JAM Software TreeSize Free version number and download URI.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Evergreen/

        .EXAMPLE
            Get-JamTreeSizeFree

            Description:
            Returns the the latest JAM Software TreeSize Free version number and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest TreeSize Free version
    $iwcParams = @{
        Uri       = $res.Get.Uri
        UserAgent = $res.Get.UserAgent
    }
    $Content = Invoke-WebRequestWrapper @iwcParams

    # Build object and output to the pipeline
    $PSObject = [PSCustomObject] @{
        Version  = $Content
        URI      = $res.Get.DownloadUri
    }
    Write-Output -InputObject $PSObject
}
