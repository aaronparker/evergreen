Function Get-WinMerge {
    <#
        .SYNOPSIS
            Get the current version and download URL for WinMerge.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-WinMerge

            Description:
            Returns the current version and download URLs for WinMerge.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.WinMerge.Uri
    If ($Null -ne $Content) {
        $Json = $Content | ConvertFrom-Json

        # Match version number
        (Split-Path -Path $Json.release.filename -Leaf) -match $script:resourceStrings.Applications.WinMerge.MatchVersion | Out-Null
        $Version = $Matches[0]

        # Construct the download URL. 
        $URI = $script:resourceStrings.Applications.WinMerge.DownloadUri -replace "#Version", $Version
        $URI = $URI -replace "#Filename", (Split-Path -Path $Json.release.filename -Leaf)

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Version
            Date    = (ConvertTo-DateTime -DateTime $Json.release.date -Pattern $script:resourceStrings.Applications.WinMerge.DatePattern)
            Size    = $Json.release.bytes
            Md5Hash = $Json.release.md5sum
            URI     = $URI
        }
        Write-Output -InputObject $PSObject
    }
}
