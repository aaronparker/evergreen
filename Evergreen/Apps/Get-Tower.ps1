Function Get-Tower {
    <#
        .SYNOPSIS
            Get the current version and download URL for Tower.

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

    foreach ($channel in $res.Get.Update.Channels) {

        # Get latest version from the update API
        $params = @{
            Uri = $res.Get.Update.Uri -replace "#channel", $channel
        }
        $Content = Invoke-RestMethodWrapper @params
        if ($Null -ne $Content) {

            # Convert the returned release data into a useable object with Version, URI etc.
            $PSObject = [PSCustomObject] @{
                Version                = "$($Content.version).$($Content.build_number)"
                Channel                = $channel
                $Content.checksum_type = $Content.checksum
                Type                   = Get-FileType -File $Content.url
                URI                    = $Content.url
            }
            Write-Output -InputObject $PSObject

            $PSObject = [PSCustomObject] @{
                Version                       = "$($Content.version).$($Content.build_number)"
                Channel                       = $channel
                $Content.msi_fingerprint_type = $Content.msi_fingerprint
                Type                          = Get-FileType -File $Content.msi_url
                URI                           = $Content.msi_url
            }
            Write-Output -InputObject $PSObject
        }
        else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return content from: $($res.Get.Update.Uri -replace "#channel", $channel)."
        }
    }
}
