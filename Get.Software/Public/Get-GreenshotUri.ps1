Function Get-GreenshotUri {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param()

    $greenshotURL="http://getgreenshot.org/downloads/"
    $raw = (Invoke-WebRequest -Uri $GreenshotURL).content
    
    # we are looking for the github download
    $pattern = "https:\/\/github\.com.+\.exe"

    # split into lines, then split into tags, #$%^ is arbitrary
    $multiLine = $raw.Split("`n").Trim().Seplace("<","#$%^<").Split("#$%^")

    # find the html tag containing the github url
    $urlLine = ($multiLine | Select-String -Pattern $pattern).ToString().Trim()

    # url line now looks like this
    # <a href="https://github.com/greenshot/greenshot/releases/download/Greenshot-RELEASE-1.2.10.6/Greenshot-INSTALLER-1.2.10.6-RELEASE.exe">
    # strip out the html tags
    $greenshotURL = $urlLine.Replace('<a href="','').Replace('">','')
    Write-Output $greenshotURL
}
