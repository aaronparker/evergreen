Function Get-TeamViewer {
    <#
        .SYNOPSIS
            Get the current version and download URL for TeamViewer.

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

    # Get the latest TeamViewer version
    $Content = Invoke-SystemNetRequest -Uri $res.Get.Update.Uri

    # Construct the output; Return the custom object to the pipeline
    If ($Null -ne $Content) {
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Content, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
            URI     = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
