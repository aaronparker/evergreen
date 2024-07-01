function Get-OmnissaHorizonClient {
    <#
        .NOTES
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

    # Get the download group and id
    $Products = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    $Product = $Products.dlgEditionsLists | Where-Object { $_.name -match $res.Get.Update.Match }

    # Build the URL to the downloads list
    $Url = $res.Get.Download.Uri -replace "#cart", $Product.dlgList.code `
        -replace "#pid", $Product.dlgList.productId `
        -replace "#rpid", $Product.dlgList.releasePackageId

    # Get the download list
    $Downloads = Invoke-EvergreenRestMethod -Uri $Url

    # Construct the output; Return the custom object to the pipeline
    foreach ($File in $Downloads.downloadFiles) {
        [PSCustomObject] @{
            Version = $File.version
            Date    = $File.releaseDate
            Sha256  = $File.sha256checksum
            Type    = Get-FileType -File $File.thirdPartyDownloadUrl
            URI     = $File.thirdPartyDownloadUrl
        } | Write-Output
    }
}
