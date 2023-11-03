function Get-ParallelsClient {
    <#
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

    # Get latest version feed
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $UpdateFeed = Invoke-EvergreenRestMethod @params

    foreach ($Architecture in $res.Get.Update.Architectures) {
        [PSCustomObject]@{
            Version      = $UpdateFeed.Product.$Architecture.Version
            Architecture = Get-Architecture -String $Architecture
            Type         = Get-FileType -File $UpdateFeed.Product.$Architecture.MsiPackageURL
            URI          = $UpdateFeed.Product.$Architecture.MsiPackageURL
        }

        [PSCustomObject]@{
            Version      = $UpdateFeed.Product.$Architecture.Version
            Architecture = Get-Architecture -String $Architecture
            Type         = Get-FileType -File $UpdateFeed.Product.$Architecture.BasicClient
            URI          = $UpdateFeed.Product.$Architecture.BasicClient
        }
    }
}
