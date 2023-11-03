Function Get-Cyberduck {
    <#
        .SYNOPSIS
            Get the current version and download URIs for Cyberduck for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Walk through each update URI (Stable, Beta and Nightly)
    ForEach ($release in $res.Get.Update.Uri.GetEnumerator()) {

        # Query the update feed
        $params = @{
            Uri         = $res.Get.Update.Uri[$release.key]
            ContentType = $res.Get.Update.ContentType
        }
        $Content = Invoke-EvergreenRestMethod @params

        If ($Null -ne $Content) {

            # Capture the URL without https:// & replace // with /
            # Then put the URL back together
            try {
                $path = [RegEx]::Match($Content.enclosure.url, $res.Get.Update.MatchUrlPath).Groups[0].Value
                $url = "https://$($path -replace "//", "/")"
            }
            catch {
                $url = $Content.enclosure.url
            }

            # Output the object
            $PSObject = [PSCustomObject] @{
                Version = "$($Content.enclosure.shortVersionString).$($Content.enclosure.version)"
                Date    = ConvertTo-DateTime -DateTime $Content.pubDate -Pattern $res.Get.Update.DatePattern
                Channel = $release.Name
                URI     = $url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
