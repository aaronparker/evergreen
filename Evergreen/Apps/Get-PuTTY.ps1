Function Get-PuTTY {
    <#
        .SYNOPSIS
            Returns the available PuTTY versions.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Get latest download url (https://the.earth.li/~sgtatham/putty/latest/ --> https://the.earth.li/~sgtatham/putty/0.xx/)
    $LatestUrl = (Invoke-WebRequest $res.Get.Uri -Method Head).BaseResponse.ResponseUri.AbsoluteUri

    # Extract the version from the redirect url
    $Version = [regex]::Match($LatestUrl, $res.Get.MatchVersion).Value

    # Go through each subfolder
    foreach ($Arch in "x86", "x64") {
        
        $ArchUrl = $LatestUrl

        switch ($Arch) {
            "x86" { $ArchUrl += "w32/"; break }             
            "x64" { $ArchUrl += "w64/"; break }
        }

        # Get the download links for each subfolder
        foreach ($Link in (Invoke-WebRequest $ArchUrl -UseBasicParsing).Links.href) {
            # Match putty.exe and *.msi
            if ([regex]::IsMatch($Link, $res.Get.MatchFileTypes)) {

                $DownloadUri = $($ArchUrl + $Link)

                # Get the headers (size, date, etc.)
                $FileHeaders = (Invoke-WebRequest $DownloadUri -Method Head).Headers

                [pscustomobject]@{
                    Version      = $Version
                    Platform     = "Windows"
                    Architecture = $Arch                    
                    Type         = [System.IO.Path]::GetExtension($Link).TrimStart(".")
                    Date         = [DateTime]$FileHeaders.Date
                    Size         = $FileHeaders.'Content-Length'
                    URI          = $DownloadUri
                }
            }
        }
    }
}
