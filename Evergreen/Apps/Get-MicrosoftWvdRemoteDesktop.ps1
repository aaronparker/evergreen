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

            $Update = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri.$channel[$architecture]
            if ($Null -ne $Update) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($Update.version)"

                # Grab the download link headers to find the file name
                $params = @{
                    Uri          = $Update.url
                    Method       = "Head"
                    ReturnObject = "Headers"
                    ErrorAction  = "SilentlyContinue"
                }
                $Headers = Invoke-WebRequestWrapper @params
                if ($Null -ne $Headers) {
                    $Date = ConvertTo-DateTime -DateTime $($Headers['Last-Modified'] | Select-Object -First 1) -Pattern $res.Get.Download.DatePattern
                    $FileName = $($Headers['Content-Disposition'] -split $res.Get.Download.SplitText)[-1]
                }
                else {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Unable to retrieve headers from $($Update.url)."
                    $Date = "Unknown"
                    $FileName = "RemoteDesktop_$($Update.version)_$architecture.msi"
                }

                # Output the version object
                $PSObject = [PSCustomObject] @{
                    Version      = $Update.version
                    Architecture = $architecture
                    Channel      = $channel
                    Date         = $Date
                    MD5          = $Update.md5
                    #SHA2         = $Update.sha2
                    Filename     = $FileName
                    URI          = $Update.url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
