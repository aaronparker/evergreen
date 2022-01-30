Function Get-7zip {
    <#
        .SYNOPSIS
            Get the current version and download URL for 7zip.

        .NOTES
            Site: https://stealthpuppy.com
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

    # Get latest version and download latest release via SourceForge API
    # Convert the returned release data into a useable object with Version, URI etc.
    $params = @{
        Uri          = $res.Get.Update.Uri
        Download     = $res.Get.Download
        MatchVersion = $res.Get.MatchVersion
    }
    $object = Get-SourceForgeRepoRelease @params
    Write-Output -InputObject $object
}
