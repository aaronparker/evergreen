Function Get-VMwareWorkstationPro {
    <#
        .SYNOPSIS
            Get the current version and download URL for the VMware Workstation Pro.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $Update = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    if ($Null -eq $Update) {
        Write-Error -Message "$($MyInvocation.MyCommand): Failed to return usable content from $($res.Get.Update.Uri)."
    }
    else {

        $File = Invoke-RestMethodWrapper -Uri $res.Get.Update.File
        if ($Null -eq $File) {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed to return usable content from $($res.Get.Update.File)."
        }
        else {

            Write-Verbose -Message "$($MyInvocation.MyCommand): filter for exe files."
            $DownloadFile = $File.downloadFiles | Where-Object { $_.fileType -eq "exe" }
            Write-Verbose -Message "$($MyInvocation.MyCommand): found $($DownloadFile.Count) object/s."

            # Build the output object
            $PSObject = [PSCustomObject] @{
                Version = $($Update.versions.name | Sort-Object -Property @{ Expression = { [System.Version]$_ }; Descending = $true } | Select-Object -First 1)
                Date    = ConvertTo-DateTime -DateTime $DownloadFile.releaseDate -Pattern "yyyy-MM-dd"
                Sha256  = $DownloadFile.sha256checksum
                Size    = $DownloadFile.fileSize
                Type    = Get-FileType -File $DownloadFile.fileName
                URI     = $res.Get.Download.Uri -replace "#filename", $DownloadFile.fileName
            }
            Write-Output -InputObject $PSObject
        }
    }
}
