function Get-1Password {
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
        [Parameter(Mandatory = $false, Position = 0)]
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
    if ($updateFeed.available -eq 1) {

        # Output the object to the pipeline from the update feed
        foreach ($item in $updateFeed) {

            # Pick a URL from the list of returns URLs
            # $Url = $($item.sources | Select-Object -Index (Get-Random -Minimum 0 -Maximum 2)).url
            $Url = $item.sources | Where-Object { $_.name -eq $res.Get.Update.CDN } | Select-Object -ExpandProperty "url"

            $PSObject = [PSCustomObject] @{
                Version = $item.version
                Type    = Get-FileType -File $Url
                URI     = $Url
            }
            Write-Output -InputObject $PSObject
        }

        # Output the MSI version of the 1Password installer
        $PSObject = [PSCustomObject] @{
            Version = $item.version
            Type    = Get-FileType -File $res.Get.Download.Uri
            URI     = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
    else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to find an available from: $($res.Get.Update.Uri)."
    }
}
