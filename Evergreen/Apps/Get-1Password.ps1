Function Get-1Password {
    <#
        .SYNOPSIS
            Get the current version and download URL for 1Password.

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
    $updateFeed = Invoke-RestMethodWrapper @params
    If ($Null -ne $updateFeed) {

        # Output the object to the pipeline
        ForEach ($item in $updateFeed.($res.Get.Update.Property)) {
            $PSObject = [PSCustomObject] @{
                Version = $item.before
                URI     = $item.url
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Throw "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
}
