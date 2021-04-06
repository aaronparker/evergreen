https://softwareupdate.vmware.com/horizon-clients/index.xml
https://softwareupdate.vmware.com/horizon-clients/viewcrt-mac/viewcrt-windows.xml
https://softwareupdate.vmware.com/horizon-clients/viewcrt-mac/viewcrt-mac.xml

https://softwareupdate.vmware.com/horizon-clients/viewcrt-windows/5.4.1/15897311/metadata.xml.gz

http://softwareupdate.vmware.com/horizon-clients/viewcrt-windows/5.4.2/15936851/VMware-Horizon-Client-5.4.2-15936851.exe.tar

Function DeGZip-File{
    param (
        $infile,
        $outfile = ($infile -replace '\.gz$','')
        )
    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
    $buffer = New-Object byte[](1024)
    while($true){
        $read = $gzipstream.Read($buffer, 0, 1024)
        if ($read -le 0){break}
        $output.Write($buffer, 0, $read)
        }
    $gzipStream.Close()
    $output.Close()
    $input.Close()
}
DeGZip-File "C:\temp\maxmind\temp.tar.gz" "C:\temp\maxmind\temp.tar"

https://scatteredcode.net/download-and-extract-gzip-tar-with-powershell/

