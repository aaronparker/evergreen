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

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    $Content = Invoke-WebContent -Uri $res.Get.Uri
    If ($Null -ne $Content) {
        $Json = $Content | ConvertFrom-Json

        # Match version number
        (Split-Path -Path $Json.release.filename -Leaf) -match $res.Get.MatchVersion | Out-Null
        $Version = $Matches[0]

        # Construct the download URL. 
        $URI = $res.Get.DownloadUri -replace "#Version", $Version
        $URI = $URI -replace "#Filename", (Split-Path -Path $Json.release.filename -Leaf)

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Version
            Date    = (ConvertTo-DateTime -DateTime $Json.release.date -Pattern $res.Get.DatePattern)
            Size    = $Json.release.bytes
            Md5Hash = $Json.release.md5sum
            URI     = $URI
        }
        Write-Output -InputObject $PSObject
    }
}
