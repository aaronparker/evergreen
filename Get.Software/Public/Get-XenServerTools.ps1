Function Get-XenServerTools {
    $Uri = "https://pvupdates.vmd.citrix.com/updates.latest.tsv"
    $TempFile = New-TemporaryFile
    Invoke-WebRequest -Uri $Uri -OutFile $TempFile
    $RawContent = Get-Content $TempFile
    $Table = $RawContent | ConvertFrom-Csv -Delimiter "`t" -Header "Uri", "Version", "Size", "Architecture", "Index"
    Write-Output $Table
}
