Function Get-TeamViewer {
    <#
        .SYNOPSIS
            Get the current version and download URL for TeamViewer.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-TeamViewer

            Description:
            Returns the current version and download URI for TeamViewer on Windows (x86, x64) and macOS.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    #region Get current version for Windows
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.TeamViewer.Uri -Raw

    # Match version number from the download URL
    # Content returned is a string - trim blank lines, split at line ends, sort and select first object to get version number
    $Sort = $Content.Trim().Split("\n") | Sort-Object | Select-Object -First 1
    If ($Sort -match $script:resourceStrings.Applications.TeamViewer.MatchVersion) {
        $Version = $Matches[0]
    }
    Else {
        $Version = "Unknown"
    }

    # Construct the output; Return the custom object to the pipeline
    $PSObject = [PSCustomObject] @{
        Version = $Version
        URI     = $script:resourceStrings.Applications.TeamViewer.DownloadUri
    }
    Write-Output -InputObject $PSObject
    #endregion
}
