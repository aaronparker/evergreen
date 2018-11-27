Function Get-VirtualBoxVersion {
    
    <#
        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    
    
    $url = "https://download.virtualbox.org/virtualbox/LATEST.TXT"

    try {
        $temp = New-TemporaryFile
        Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $temp -ErrorAction SilentlyContinue
        $Version = get-content $temp
        Write-Output $Version
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
    }
}