function Get-VMwareRelatedDLGList {
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $CategoryMap,

        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ProductMap,

        [Parameter(Mandatory = $true,
            Position = 2,
            ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VersionMap,

        [Parameter(Mandatory = $false)]
        [ValidateSet('PRODUCT_BINARY', 'DRIVERS_TOOLS', 'OPEN_SOURCE', 'CUSTOM_ISO', 'ADDONS')]
        [System.String] $DLGType = 'PRODUCT_BINARY'
    )

    process {
        $APIResource = 'getRelatedDLGList'
        $queryParameters = @{
            category = $CategoryMap
            product  = $ProductMap
            version  = $VersionMap
            dlgType  = $DLGType
        }
        $queryString = ( $queryParameters.GetEnumerator() | ForEach-Object { "&$($_.Key)=$($_.Value)" }) -join ''
        $params = @{
            Uri             = "$(Get-VMwareAPIPath)/$($APIResource)?$($queryString.TrimStart('&'))"
        }
        $WebResult = Invoke-RestMethodWrapper @params
        Write-Output -InputObject $WebResult.dlgEditionsLists.dlgList
    }
}
