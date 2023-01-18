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
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
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
                $Update = Invoke-RestMethodWrapper -Uri $Redirect.ResponseUri.AbsoluteUri

                if ($null -ne $Update) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($Update.version)"
                    $Date = ConvertTo-DateTime -DateTime $($Redirect.Headers['Last-Modified'] | Select-Object -First 1) -Pattern $res.Get.Download.DatePattern
                    $FileName = $($Redirect.Headers['Content-Disposition'] -split $res.Get.Download.SplitText)[-1] -replace "\.json$", ".msi"

                    # Output the version object
                    $PSObject = [PSCustomObject] @{
                        Version      = $Update.version
                        Architecture = $architecture
                        Channel      = $channel
                        Date         = $Date
                        MD5          = $Update.md5
                        Sha2         = $Update.sha2
                        Filename     = $FileName
                        URI          = $Update.url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
