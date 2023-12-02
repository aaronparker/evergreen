Function Get-1Password7 {
    <#
        .SYNOPSIS
            Get the current version and download URL for 1Password 7.

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

    # Get latest version and download latest release via update API
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $updateFeed = Invoke-EvergreenRestMethod @params
    if ($Null -ne $updateFeed) {

        # Filter for the latest version
        $item = $updateFeed.($res.Get.Update.Property) | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.before }; Descending = $true } | `
            Select-Object -First 1

        # Output the object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $item.before
            URI     = $item.url
        }
        Write-Output -InputObject $PSObject
    }
    else {
        Write-Error -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
}
