Function Get-GreenShotVersion {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([Version])]
    Param()

    $GreenshotURL = Get-GreenshotUri
    $versionPattern = "\d+\.\d+\.\d+\.\d+"

    # get the URL and split it on the forward slash, then look for the version pattern
    $productTitle = ($GreenshotURL.Split("/") | Select-String -Pattern $versionPattern | Select-Object -First 1).ToString().Trim()
    
    # there will be two because they put the version in the EXE and also in the path as a subfolder.
    $GreenshotVersion = [Version]::new(($productTitle.Split('-') | Select-String -Pattern $versionPattern | Select-Object -First 1).ToString().Trim())
    write-output $GreenshotVersion
}
