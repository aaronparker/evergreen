function Get-AWSAppStreamClient {
    <#
        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the update feed from RSS
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Get the latest version from the feed
    $LatestItem = $UpdateFeed | Where-Object { $_.title -match $res.Get.Update.MatchText } | Select-Object -First 1
    $LatestVersion = [RegEx]::Match(($LatestItem | Select-Object -ExpandProperty "description"), $res.Get.Update.MatchVersion).Captures.Groups[1].Value

    [PSCustomObject]@{
        Version = $LatestVersion
        Date    = $LatestItem.pubDate
        Type    = Get-FileType -File $res.Get.Download.Uri
        URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $LatestVersion
    } | Write-Output
}
