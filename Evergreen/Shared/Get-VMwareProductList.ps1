function Get-VMwareProductList {
    <#
        .EXTERNALHELP Evergreen.VMware-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false)]
        [System.String] $Name
    )

    $APIResource = 'getProductsAtoZ'
    $params = @{
        Uri = "$(Get-VMwareAPIPath)/${APIResource}"
    }
    $WebResult = Invoke-EvergreenRestMethod @params

    $FilteredProductList = $WebResult.productCategoryList.ProductList
    if ($PSBoundParameters.ContainsKey('Name')) {
        $FilteredProductList = $FilteredProductList | Where-Object -FilterScript { $_.Name -eq $Name }
    }

    $Result = $FilteredProductList | ForEach-Object -Process {
        $Action = $_.actions | Where-Object -FilterScript { $_.linkname -eq "Download Product" }
        [PSCustomObject]@{
            Name        = $_.Name
            CategoryMap = $($Action.target -split '/')[-3]
            ProductMap  = $($Action.target -split '/')[-2]
            VersionMap  = $($Action.target -split '/')[-1]
        }
    }
    Write-Output -InputObject $Result
}
