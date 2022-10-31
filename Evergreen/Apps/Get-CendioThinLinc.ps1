Function Get-CendioThinLinc {
    <#
        .SYNOPSIS
            Get the current version and download URI for the current release of ThinLinc.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
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
    $Url = Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri

    # Construct the output; Return the custom object to the pipeline
    if ($Null -ne $Url) {
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Url.ResponseUri.AbsoluteUri, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
            URI     = $Url.ResponseUri.AbsoluteUri
        }
        Write-Output -InputObject $PSObject
    }
}
