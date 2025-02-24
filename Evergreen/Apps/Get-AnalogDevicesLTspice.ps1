function Get-AnalogDevicesLTspice {
    <#
        .NOTES
            Author: Aaron Parker
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
        $Updates = ConvertFrom-IniFile -InputObject ($UpdateFeed -replace ";aiu;")

        # Output the latest version
        [PSCustomObject]@{
            Version = $Updates.Update.Version.Trim()
            Date    = $Updates.Update.ReleaseDate.Trim()
            Size    = $Updates.Update.Size.Trim()
            Sha256  = $Updates.Update.SHA256.Trim()
            Type    = Get-FileType -File $Updates.Update.URL
            URI     = $Updates.Update.URL.Trim()
        } | Write-Output
    }
}
