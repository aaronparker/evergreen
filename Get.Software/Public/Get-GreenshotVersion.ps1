Function Get-GreenShotVersion {
    <#
        .SYNOPSIS
            Returns the latest Greenshot version number.

        .DESCRIPTION
            Returns the latest Greenshot version number.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-GreenShotVersion

            Description:
            Returns the latest Greenshot version number.
    #>
    [CmdletBinding()]
    [OutputType([Version])]
    Param()

    $GreenshotURL = Get-GreenshotUri
    $versionPattern = "\d+\.\d+\.\d+\.\d+"

    # get the URL and split it on the forward slash, then look for the version pattern
    $productTitle = ($GreenshotURL.Split("/") | Select-String -Pattern $versionPattern `
            | Select-Object -First 1).ToString().Trim()
    
    # there will be two because they put the version in the EXE and also in the path as a subfolder.
    $GreenshotVersion = [Version]::new(($productTitle.Split('-') | Select-String -Pattern $versionPattern `
                | Select-Object -First 1).ToString().Trim())

    Write-Output $GreenshotVersion
}
