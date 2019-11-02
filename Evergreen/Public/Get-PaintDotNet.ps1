Function Get-PaintDotNet {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the Paint.NET updates feed
    $Content = Invoke-WebContent -Uri $res.Get.Uri

    If ($Null -ne $Content) {
        # Match version and download strings from the content
        $Content -match $res.Get.MatchVersion | Out-Null
        $Version = $Matches[1].Trim()
    
        # Build the output object
        If ($Version) {
            $Content -match ($res.Get.MatchDownload -replace "#Version", ($Version -replace "\.", "\.")) | Out-Null
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
}
