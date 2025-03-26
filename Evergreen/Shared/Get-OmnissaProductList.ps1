function Get-OmnissaProductList {
    <#
        .EXTERNALHELP Evergreen.Omnissa-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false)]
        [System.String] $Name
    )

    $APIResource = 'getProductsAtoZ'
    $params = @{
        Uri       = "$(Get-OmnissaAPIPath)/${APIResource}"
        UserAgent = "Evergreen/2504.111"
    }
    $WebResult = Invoke-EvergreenRestMethod @params

    $FilteredProductList = $WebResult.productCategoryList.ProductList
    if ($PSBoundParameters.ContainsKey('Name')) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Filtering on Name: $Name"
        $FilteredProductList = $FilteredProductList | Where-Object -FilterScript { $_.name -eq $Name }
    }

    $Result = $FilteredProductList | ForEach-Object -Process {
        $Action = $_.actions | Where-Object -FilterScript { $_.linkname -eq "View Download Components" }
        [PSCustomObject]@{
            Name        = $_.Name
            CategoryMap = $($Action.target -split '/')[-3]
            ProductMap  = $($Action.target -split '/')[-2]
            VersionMap  = $($Action.target -split '/')[-1]
        }
    }
    Write-Output -InputObject $Result
}
