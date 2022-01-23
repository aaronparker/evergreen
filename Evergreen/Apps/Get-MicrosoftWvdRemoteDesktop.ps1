Function Get-MicrosoftWvdRemoteDesktop {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop client for Windows Virtual Desktop.

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

    ForEach ($channel in $res.Get.Download.Uri.Keys) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Querying for channel: $channel."

        ForEach ($architecture in $res.Get.Download.Uri.$channel.Keys) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Querying for architecture: $architecture."

            # Grab the download link headers to find the file name
            $params = @{
                Uri          = $res.Get.Download.Uri.$channel[$architecture]
                Method       = "Head"
                ReturnObject = "Headers"
            }
            $Headers = Invoke-WebRequestWrapper @params

            # Match filename
            If ($Null -ne $Headers) {
                $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

                # Build the download URL from the headers returned from the API
                # TODO: Update this to better handle changes in the URL structure
                $Url = "$($res.Get.Download.ApiUri)/$($Headers.($res.Get.Download.ApiHeader1))/$($Headers.($res.Get.Download.ApiHeader2))/$($Headers.($res.Get.Download.ApiHeader3))"

                # Construct the output; Return the custom object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchVersion).Captures.Value
                    Architecture = $architecture
                    Channel      = $channel
                    Date         = ConvertTo-DateTime -DateTime $($Headers['Last-Modified'] | Select-Object -First 1) -Pattern $res.Get.Download.DatePattern
                    Size         = $Headers['Content-Length'] | Select-Object -First 1
                    Filename     = $Filename
                    URI          = $Url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
