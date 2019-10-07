Function Get-PaintDotNet {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    Param()

    # Read the Paint.NET updates feed
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.PaintDotNET.Uri

    # Match version and download strings from the content
    $Content -match $script:resourceStrings.Applications.PaintDotNET.MatchVersion | Out-Null
    $Version = $Matches[1].Trim()
    
    # Build the output object
    If ($Version) {
        $Content -match ($script:resourceStrings.Applications.PaintDotNET.MatchDownload -replace "#Version", ($Version -replace "\.", "\.")) | Out-Null
        $Download = $Matches[1].Split(",")[0]
        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = $Download
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "Failed to find version number from feed."
    }
}
