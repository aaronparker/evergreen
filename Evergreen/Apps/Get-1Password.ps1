Function Get-1Password {
    <#
        .SYNOPSIS
            Get the current version and download URL for 1Password 8 and later.

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
        if ($updateFeed.available -eq 1) {

            # Output the object to the pipeline
            foreach ($item in $updateFeed) {
                $PSObject = [PSCustomObject] @{
                    Version = $item.version
                    URI     = $($item.sources | Select-Object -Index (Get-Random -Minimum 0 -Maximum 2)).url
                }
                Write-Output -InputObject $PSObject
            }
        }
        else {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to find an available from: $($res.Get.Update.Uri)."
        }
    }
    else {
        Write-Error -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
}
