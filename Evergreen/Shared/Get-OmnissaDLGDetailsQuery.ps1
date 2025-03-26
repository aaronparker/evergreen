function Get-OmnissaDLGDetailsQuery {
    [OutputType("System.String")]
    param (
        [Parameter(Mandatory = $true)]
        [System.String] $DownloadGroup,

        [Parameter(Mandatory = $false)]
        [System.String] $Locale = 'en_US'
    )

    $APIResource = 'details'
    $queryParameters = @{
        locale        = $Locale
        downloadGroup = $DownloadGroup
    }
    $queryString = ($queryParameters.GetEnumerator() | ForEach-Object { "&$($_.Key)=$($_.Value)" }) -join ''
    $DlgQuery = "$(Get-OmnissaAPIPath -Endpoint 'dlg')/$($APIResource)?$($queryString.TrimStart('&'))"
    Write-Verbose -Message "$($MyInvocation.MyCommand): $DlgQuery"
    return $DlgQuery
}
