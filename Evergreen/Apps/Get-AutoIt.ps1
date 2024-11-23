function Get-AutoIt {
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

        # Convert the INI update feed to an object
        $Updates = ConvertFrom-IniFile -InputObject $UpdateFeed
        foreach ($Key in $Updates.Keys) {

            # Output the latest version
            [PSCustomObject]@{
                Version = $Updates[$Key].version
                Date    = ConvertTo-DateTime -DateTime $Updates[$Key].filetime -Pattern "yyyyMMddHHmmss"
                Channel = $(if ($Key -match "Beta$") { "Beta" } else { "Stable" })
                Size    = $Updates[$Key].filesize
                Type    = Get-FileType -File $Updates[$Key].setup
                URI     = $Updates[$Key].setup
            } | Write-Output
        }
    }
}
