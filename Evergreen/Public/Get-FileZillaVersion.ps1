Function Get-FileZilla {
    
    <#
        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
    #>
    
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()
    $url = "https://filezilla-project.org/download.php?type=client"

    try {
        $web = Invoke-WebRequest -UseBasicParsing -Uri $url -ErrorAction SilentlyContinue
        $str1 = $web.tostring() -split "[`r`n]" | select-string "The latest stable version of FileZilla Client is"
        $str2 = $str1 -replace "<p>The latest stable version of FileZilla Client is "
        $Version = $str2 -replace "</p>"
        Write-Output -InputObject $Version
    }
    catch {
        Throw "Failed to connect to URL: $url with error $_."
    }
}
