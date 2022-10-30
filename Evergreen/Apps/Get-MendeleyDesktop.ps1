function Get-MendeleyDesktop {
    <#
        .SYNOPSIS
            Get the current version and download URL for Mendeley Desktop.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
            Based on Get-TelerikFiddlerEverywhere.ps1
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    $Url = Resolve-InvokeWebRequest -Uri $res.Get.Download.Uri

    # Construct the output; Return the custom object to the pipeline
    if ($Null -ne $Url) {
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Url, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
            URI     = $Url
        }
        Write-Output -InputObject $PSObject
    }
}
