Function Get-PDF24 {
    <#
        .SYNOPSIS
            Returns the available PDF24 versions.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Get latest download url (https://stx.pdf24.org/products/pdf-creator/download/ --> https://stx.pdf24.org/products/pdf-creator/download/pdf24-creator-xx.x.x.exe)
    $DownloadUri = (Invoke-WebRequest $res.Get.Uri -Method Head).BaseResponse.ResponseUri.AbsoluteUri

    $Version = [regex]::Match($DownloadUri, "-(\d+\.)?(\d+\.)?(\*|\d+)").Value.TrimStart("-")

    foreach ($Type in "exe", "msi") {
                
        if ($Type -eq "msi") {
            $DownloadUri = $DownloadUri.Replace(".exe", ".msi")
        }

        $FileHeaders = (Invoke-WebRequest $DownloadUri -Method Head).Headers

        [pscustomobject]@{
            Version      = $Version
            Platform     = "Windows"
            Architecture = "x64"
            Type         = $Type
            Date         = [DateTime]$FileHeaders.Date
            Size         = $FileHeaders.'Content-Length'
            URI          = $DownloadUri
        }
    }
}
