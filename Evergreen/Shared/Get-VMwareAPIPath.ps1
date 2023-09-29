function Get-VMwareAPIPath {
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType("System.String")]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('products', 'dlg')]
        [System.String] $Endpoint = "products"
    )
    $ApiPath = "https://customerconnect.vmware.com/channel/public/api/v1.0/${Endpoint}"
    Write-Verbose -Message "$($MyInvocation.MyCommand): Return $ApiPath"
    return $ApiPath
}