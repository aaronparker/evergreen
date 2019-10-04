Function Get-FileZillaVersion {
    
    <#
        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    
    
    $url = "https://filezilla-project.org/download.php?type=client"

    try {
        $web = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
        $str1 = $web.tostring() -split "[`r`n]" | select-string "The latest stable version of FileZilla Client is"
        $str2 = $str1 -replace "<p>The latest stable version of FileZilla Client is "
        $Version = $str2 -replace "</p>"
        Write-Output $Version
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
    }
}