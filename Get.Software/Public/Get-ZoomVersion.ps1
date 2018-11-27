Function Get-ZommVersion {
    
    <#
        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    
    
    $url = "https://zoom.us/download"

    try {
        $web = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
        $str1 = $web.tostring() -split "[`r`n]" | select-string "Version" | Select -First 1
        $str2 = $str1 -replace "						</div>"
        $Version = $str2 -replace "Version "
        Write-Output $Version
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
    }
}