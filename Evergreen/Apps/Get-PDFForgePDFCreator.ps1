Function Get-PDFForgePDFCreator {
    <#
        .SYNOPSIS
            Get the current version and download URL for PDFForge PDFCreator.

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

    # Query the update API
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Update = Invoke-EvergreenRestMethod @params
    if ($Null -ne $Update) {

        # Select the latest version
        $LatestUpdate = $Update | Where-Object { $_.isStable -eq $True } | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
            Select-Object -First 1

        $PSObject = [PSCustomObject] @{
            Version  = $LatestUpdate.version
            Date     = ConvertTo-DateTime -DateTime $LatestUpdate.releaseDate -Pattern "yyyy-MM-dd"
            Size     = $LatestUpdate.downloads[0].size
            MD5      = $LatestUpdate.downloads[0].md5
            Filename = $LatestUpdate.downloads[0].filename
            URI      = $LatestUpdate.downloads[0].sourceUrl
        }
        Write-Output -InputObject $PSObject
    }
}
