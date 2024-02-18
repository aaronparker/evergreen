function Get-CitrixShareFile {
    <#
        .SYNOPSIS
            Returns the current Citrix ShareFile for Windows releases.

        .NOTES
            Author: Tschuegy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the Citrix ShareFile for Windows for updater feed
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $UpdateFeed = Invoke-EvergreenRestMethod @params

    # Walk through each node to output details
    if ($null -ne $UpdateFeed) {

        # Select the latest version
        $Latest = $UpdateFeed | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } -ErrorAction "SilentlyContinue" | `
            Select-Object -First 1

        # Create the output object
        $PSObject = [PSCustomObject] @{
            Version = $Latest.enclosure.version
            Date    = ConvertTo-DateTime -DateTime $($Latest.pubDate) -Pattern $($res.Get.Update.DatePattern)
            Size    = $(if ($Latest.enclosure.length) { $Latest.enclosure.length } else { "Unknown" })
            Hash    = $Latest.enclosure.dsaSignature
            URI     = $Latest.enclosure.url
        }
        Write-Output -InputObject $PSObject
    }
}
