function Get-AdvancedInstaller {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the update feed
    $params = @{
        Uri       = $res.Get.Update.Uri
        UserAgent = $res.Get.Update.UserAgent
    }
    $UpdateFeed = Invoke-EvergreenRestMethod @params
    if ($null -ne $UpdateFeed) {

        # Convert the INI update feed to an object, replace strings that break conversion
        $Updates = ConvertFrom-IniFile -InputObject ($UpdateFeed -replace ";aiu;", "" -replace "\[advinst", "[")

        # Get the latest version
        $LatestVersion = $Updates.Keys | `
            Sort-Object -Property @{ Expression = { [System.Version]$_ }; Descending = $true } | `
            Select-Object -First 1
        $LatestUpdate = $Updates[$LatestVersion]

        # Output the latest version
        [PSCustomObject]@{
            Version = $LatestVersion
            Size    = $LatestUpdate.Size.Trim()
            Sha256  = $LatestUpdate.SHA256.Trim()
            Type    = Get-FileType -File $LatestUpdate.URL
            URI     = $LatestUpdate.URL.Trim()
        } | Write-Output
    }
}
