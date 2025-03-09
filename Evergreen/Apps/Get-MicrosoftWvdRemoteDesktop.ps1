Function Get-MicrosoftWvdRemoteDesktop {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop client for Azure Virtual Desktop.

        .NOTES
            Site: https://stealthpuppy.com
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

    foreach ($channel in $res.Get.Update.Uri.Keys) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Querying for channel: $channel."

        foreach ($architecture in $res.Get.Update.Uri.$channel.Keys) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Querying for architecture: $architecture."
            $Redirect = Resolve-SystemNetWebRequest -Uri $res.Get.Update.Uri.$channel[$architecture]
            if ($null -ne $Redirect) {

                $Update = Invoke-EvergreenRestMethod -Uri $Redirect.ResponseUri.AbsoluteUri
                if ($null -ne $Update) {

                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($Update.version)"
                    $Date = ConvertTo-DateTime -DateTime $($Redirect.Headers['Last-Modified'] | Select-Object -First 1) -Pattern $res.Get.Download.DatePattern

                    # Output the version object
                    $PSObject = [PSCustomObject] @{
                        Version      = $Update.version
                        Date         = $Date
                        Channel      = $channel
                        MD5          = $Update.md5
                        Sha2         = $Update.sha2
                        Architecture = $architecture
                        URI          = $Update.url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
