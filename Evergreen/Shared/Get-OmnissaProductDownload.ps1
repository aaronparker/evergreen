function Get-OmnissaProductDownload {
    <#
        .EXTERNALHELP Evergreen.Omnissa-help.xml
    #>
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [System.String[]] $Name
    )

    process {
        foreach ($Product in $Name) {
            $OmnissaProduct = Get-OmnissaProductList -Name $Product
            $OmnissaDLG = $OmnissaProduct | Get-OmnissaRelatedDLGList

            foreach ($Dlg in $OmnissaDLG) {
                $params = @{
                    Uri = $(Get-OmnissaDLGDetailsQuery -DownloadGroup $Dlg.code)
                }
                $DownloadFiles = $(Invoke-EvergreenRestMethod @params).downloadFiles
                Write-Verbose -Message "$($MyInvocation.MyCommand): $($DownloadFiles.Count) files found for $($Dlg.code)"

                foreach ($File in $DownloadFiles) {
                    if ([System.String]::IsNullOrEmpty($File.title)) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Skipping file with no title"
                    }
                    else {
                        $Result = [PSCustomObject]@{
                            Version     = $File.version
                            ReleaseDate = $([System.DateTime]::ParseExact($File.releaseDate, "yyyy-MM-dd", [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat))
                            Md5         = $File.md5checksum
                            Sha256      = $File.sha256checksum
                            Size        = $File.fileSize
                            Type        = Get-FileType -File $File.fileName
                            URI         = "https://download2.omnissa.com/software/$($Dlg.code)/$($File.fileName)"
                        }
                        Write-Output -InputObject $Result
                    }
                }
            }
        }
    }
}
