function Get-PaloAltoGlobalProtect {
    <#
        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get latest version and download latest release
    $params = @{
        Uri = $res.Get.Download.Uri
    }
    $DownloadFeed = Invoke-EvergreenRestMethod @params

    # # Select the list of versions from the ListBucketResult.Contents.Key property in the download feed
    # $Versions = ($DownloadFeed.ListBucketResult.Contents.Key | `
    #         Where-Object { $_ -match $res.Get.Download.MatchFileType }) `
    #     -replace $res.Get.Download.MatchFileName

    # Select the item with the latest date and export the date to $LatestDate
    $LatestDate = $DownloadFeed.ListBucketResult.Contents | `
        Sort-Object -Property @{ Expression = { [System.DateTime]$_.LastModified }; Descending = $true } | `
        Select-Object -ExpandProperty LastModified -First 1
    Write-Verbose -Message "$($MyInvocation.MyCommand): Found date: $LatestDate"

    # Get the latest version from the list of versions based on the most recent date
    $LatestVersions = $DownloadFeed.ListBucketResult.Contents | `
        Where-Object { $_.LastModified -match $LatestDate -and $_.Key -match $res.Get.Download.MatchFileType }
    Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($LatestVersions.Count) versions with date: $LatestDate"

    # Return the list of downloads for the latest version
    foreach ($Item in $LatestVersions) {
        [PSCustomObject]@{
            Version      = $Item.Key -replace $res.Get.Download.MatchFileName
            Date         = ConvertTo-DateTime -DateTime $Item.LastModified -Pattern $res.Get.Download.DateTimePattern
            Architecture = Get-Architecture -String $Item.Key
            Type         = Get-FileType -File $Item.Key
            URI          = "$($res.Get.Download.Uri)/$($Item.Key)"
        }
    }
}
