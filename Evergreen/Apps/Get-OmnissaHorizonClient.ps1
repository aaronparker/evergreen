function Get-OmnissaHorizonClient {
    <#
        .NOTES
            Author: Aaron Parker, Dan Gough
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # $Output = Get-VMwareProductList -Name $res.Get.Download.ProductName | `
    #     Get-VMwareProductDownload | `
    #     Where-Object { $_.URI -match $res.Get.Download.MatchFileTypes } | `
    #     Sort-Object -Property "ReleaseDate" | `
    #     Select-Object -Last 1 | `
    #     ForEach-Object { $_.Version = $_.Version -replace $res.Get.Download.ReplaceText, ""; $_ }
    # Write-Output -InputObject $Output

    $params = @{
        Uri = $res.Get.Download.Uri
    }
    $Response = Invoke-EvergreenRestMethod @params
    $Product = $Response.dlgEditionsLists.Where({ $_.name -eq $res.Get.Download.ProductName }).dlgList

    $params = @{
        Uri = $res.Get.Download.QueryUri -replace "#ProductCode", $Product.code `
            -replace "#ProductId", $Product.productId `
            -replace "#PackageId", $Product.releasePackageId
    }
    $details = Invoke-EvergreenRestMethod @params

    foreach ($File in $details.downloadFiles) {

        $InternalVersion = [RegEx]::Match($File.thirdPartyDownloadUrl, $res.Get.Download.MatchVersion).Captures.Groups[1].Value

        $PSObject = [PSCustomObject] @{
            Version         = $File.version
            InternalVersion = "$InternalVersion-$($File.build)"
            Date            = ConvertTo-DateTime -DateTime $File.releaseDate -Pattern $res.Get.Download.DateFormat
            Sha256          = $File.sha256checksum
            Size            = $File.fileSize
            Type            = Get-FileType -File $File.thirdPartyDownloadUrl
            URI             = $File.thirdPartyDownloadUrl
        }
        Write-Output -InputObject $PSObject
    }
}
