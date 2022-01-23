Function Get-GeekSoftwarePDF24Creator {
    <#
        .SYNOPSIS
            Get the current version and download URL for GeekSoftwarePDF24Creator.

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
    $Content = Resolve-InvokeWebRequest -Uri $res.Get.Download.Uri

    # Construct the output; Return the custom object to the pipeline
    If ($Null -ne $Content) {
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Content, $res.Get.Download.MatchVersion).Value.TrimStart("-")
            Type    = "Exe"
            URI     = $Content
        }
        Write-Output -InputObject $PSObject

        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Content, $res.Get.Download.MatchVersion).Value.TrimStart("-")
            Type    = "Msi"
            URI     = $Content -replace ".exe$", ".msi"
        }
        Write-Output -InputObject $PSObject
    }
}
