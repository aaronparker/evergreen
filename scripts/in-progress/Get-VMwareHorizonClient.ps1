# https://softwareupdate.vmware.com/horizon-clients/index.xml
# "https://softwareupdate.vmware.com/horizon-clients/viewcrt-windows/8.2.0/17759012/VMware-Horizon-Client-2103-8.2.0-17759012.exe.tar"
# "https://download3.vmware.com/software/view/viewclients/CART22FQ1/VMware-Horizon-Client-2103-8.2.0-17759012.exe"

# Horizon Client
$r = Invoke-RestMethod -Uri "https://softwareupdate.vmware.com/horizon-clients/viewcrt-mac/viewcrt-windows.xml"
$v = $r.metaList.metadata | Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } | Select-Object -First 1
$url = "https://softwareupdate.vmware.com/horizon-clients/"
$data = "$url$($v.Url.TrimStart("../"))"

$ZipFile = Join-Path -Path $env:TMPDIR -ChildPath (Split-Path -Path $data -Leaf)
$ExpandFile = $ZipFile -replace "\.gz$", ""

Invoke-WebRequest -Uri $data -OutFile $ZipFile
Expand-GzipArchive -Path $ZipFile -DestinationPath $ExpandFile
$Content = Get-Content -Path $ExpandFile
Remove-Item -Path $ZipFile
Remove-Item -Path $ExpandFile

[System.XML.XMLDocument] $xmlDocument = $Content
$Version = (Select-Xml -Xml $xmlDocument -XPath "//productList" | Select-Object –ExpandProperty "node").product
$FileName = (Select-Xml -Xml $xmlDocument -XPath "//relativePath" | Select-Object –ExpandProperty "node").'#text'

# Object
$PSObject = [PSCustomObject] @{
    Version = "$($Version.version).$($Version.buildNumber)"
    URI     = "$url$($Version.productId)/$($Version.version)/$($Version.buildNumber)/$($FileName)"
}
Write-Output -InputObject $PSObject
