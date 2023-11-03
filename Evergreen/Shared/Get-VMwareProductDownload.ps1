function Get-VMwareProductDownload {
    <#
        .EXTERNALHELP Evergreen.VMware-help.xml
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
            $VMwareProduct = Get-VMwareProductList -Name $Product
            $VMwareDLG = $VMwareProduct | Get-VMwareRelatedDLGList

            foreach ($Dlg in $VMwareDLG) {
                $params = @{
                    Uri = $(Get-VMwareDLGDetailsQuery -DownloadGroup $Dlg.code)
                }
                $DownloadFiles = $(Invoke-EvergreenRestMethod @params).downloadFiles

                foreach ($File in $DownloadFiles) {
                    if ([System.String]::IsNullOrEmpty($File.title)) {
                    }
                    else {
                        $Result = [PSCustomObject]@{
                            Version     = $File.version
                            ReleaseDate = $([System.DateTime]::ParseExact($File.releaseDate, "yyyy-MM-dd", [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat))
                            Md5         = $File.md5checksum
                            Sha256      = $File.sha256checksum
                            Size        = $File.fileSize
                            Type        = Get-FileType -File $File.fileName
                            URI         = "https://download3.vmware.com/software/$($Dlg.code)/$($File.fileName)"
                        }
                        Write-Output -InputObject $Result
                    }
                }
            }
        }
    }
}
