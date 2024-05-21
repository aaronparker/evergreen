Function Get-VMwareOSOptimizationTool {
    <#
        .SYNOPSIS
            Get the current version and download URL for the VMware OS Optimization Tool.

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

    $Update = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    if ($Null -eq $Update) {
        Write-Error -Message "$($MyInvocation.MyCommand): Failed to return usable content from $($res.Get.Update.Uri)."
    }
    else {

        $FileUrl = $res.Get.Update.File -replace "#releasePackageId", $Update.product.releasePackageId
        $File = Invoke-EvergreenRestMethod -Uri $FileUrl
        if ($Null -eq $File) {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed to return usable content from $FileUrl."
        }
        else {

            Write-Verbose -Message "$($MyInvocation.MyCommand): filter for files."
            $DownloadFile = $File.downloadFiles | Where-Object { $_.fileType -match "exe|zip" }
            Write-Verbose -Message "$($MyInvocation.MyCommand): found $($DownloadFile.Count) object/s."

            # Build the output object
            foreach ($Item in $DownloadFile) {
                $PSObject = [PSCustomObject] @{
                    Version = $($Update.versions.name | Select-Object -First 1)
                    Date    = ConvertTo-DateTime -DateTime $Item.releaseDate -Pattern "yyyy-MM-dd"
                    Sha256  = $Item.sha256checksum
                    Size    = $Item.fileSize
                    Type    = Get-FileType -File $Item.fileName
                    Title   = $Item.title
                    URI     = $res.Get.Download.Uri -replace "#container", $($Update.versions.id | Select-Object -First 1) -replace "#filename", $Item.fileName
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
