function Decompress-GZip($Path, $Destination) {
    $inStream = New-Object System.IO.FileStream $Path, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $gzipStream = New-Object System.IO.Compression.GZipStream $inStream, ([IO.Compression.CompressionMode]::Decompress)
    $outStream = New-Object System.IO.FileStream $Destination, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $buffer = New-Object byte[](1024)
    while (($read = $gzipStream.Read($buffer, 0, 1024)) -gt 0) {
        $outStream.Write($buffer, 0, $read)
    }
    $gzipStream.Close()
    $outStream.Close()
    $inStream.Close()
}


$Products = @(
    @{
        ProductName  = 'VMware Workstation Pro'
        URL          = 'https://softwareupdate.vmware.com/cds/vmw-desktop/ws-windows.xml'
        MajorVersion = 17
    }
    @{
        ProductName  = 'VMware Workstation Player'
        URL          = 'https://softwareupdate.vmware.com/cds/vmw-desktop/player-windows.xml'
        MajorVersion = 17
    }
    @{
        ProductName = 'VMware Remote Console'
        URL         = 'https://softwareupdate.vmware.com/cds/vmw-desktop/vmrc-windows.xml'
        #MajorVersion = 12
    }
)

foreach ($Product in $Products) {
    try {
        $XML = Invoke-RestMethod -Uri $Product.URL -DisableKeepAlive
    }
    catch {
        Write-Error "Failed to download $($Product.URL): $_"
        continue
    }

    $MajorVersions = ($XML.metaList.metadata.url | Select-String -Pattern '\d+').Matches.Groups.Value | Sort-Object -Unique
    if ($Product.MajorVersion) {
        $MajorVersions = $MajorVersions | Where-Object { $_ -eq $Product.MajorVersion }
    }

    foreach ($MajorVersion in $MajorVersions) {
        try {
            $Version = (($XML.metaList.metadata.url | Select-String -Pattern "$MajorVersion(?:\.\d+)+").Matches.Groups.Value | ForEach-Object { [version]$_ } | Sort-Object -Descending | Select-Object -First 1).ToString()
            $MetadataURL = 'https://softwareupdate.vmware.com/cds/vmw-desktop/' + ($XML.metaList.metadata.url | Where-Object { $_ -match "/$Version/(?!.*packages)" })
            $Download = Save-File -Uri $MetadataURL
            $MetadataPath = $Download.FullName -Replace '\.gz$'
            Decompress-GZip -Path $Download.FullName -Destination $MetadataPath
            $MetadataXML = [xml](Get-Content -Path $MetadataPath)

            $URL = (Split-Path $MetadataURL -Parent) + $MetadataXML.metadataResponse.bulletin.componentList.component.relativePath.'#text'

            [PSCustomObject]@{
                Name         = $Product.ProductName
                MajorVersion = $MajorVersion
                Version      = $Version
                URI          = $URL
            }
        }
        catch {
            Write-Error "Error: $_"
            continue
        }
    }
}
