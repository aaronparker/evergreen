function Get-DockerDesktop {
    <#
        .SYNOPSIS
            Returns the available Docker Desktop versions.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the releases data
    $Updates = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Select the latest version
    $Latest = $Updates | `
        Sort-Object -Property @{ Expression = { [System.Version]$_.enclosure.shortVersionString }; Descending = $true } | `
        Select-Object -First 1

    # Output the latest version
    foreach ($Item in $Latest.enclosure.url) {
        $PSObject = [PSCustomObject] @{
            Version = $Latest.enclosure.shortVersionString
            Build   = $Latest.enclosure.version
            Size    = $Latest.enclosure.length
            Type    = Get-FileType -File $Item
            URI     = $Item
        }
        Write-Output -InputObject $PSObject
    }
}
