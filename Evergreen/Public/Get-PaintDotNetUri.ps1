Function Get-PaintDotNetUri {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param()
    
    $sourceUrl = "https://www.dotpdn.com/downloads/pdn.html"
    $raw = Invoke-WebRequest -UseBasicParsing -Uri $sourceUrl

    $multiline = $raw.content.split("`n").trim()
    $justTags = $multiline.replace("<","#$%^<").split("#$%^")
    $pattern = "paint\.net\S*(\d+\.)+\d\S*\.(zip|exe)"

    #https://www.dotpdn.com/files/paint.net.4.1.1.install.zip
    
    $relativehtml = ($justtags | Select-String -Pattern $pattern | Select-Object -First 1).tostring().trim()
    $relativeURL = $relativehtml.replace('<a href="','').replace('">','')
    
    $dotdotreplacement = "https://www.dotpdn.com"
    $finalurl = $relativeURL.replace("..",$dotdotreplacement)
    Write-Output $finalurl
}
