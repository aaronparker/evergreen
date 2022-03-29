Function Get-MicrosoftWvdRtcService {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop WebRTC Redirector service.

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

    # Grab the download link headers to find the file name
    $params = @{
        Uri          = $res.Get.Download.Uri
        Method       = "Head"
        ReturnObject = "Headers"
    }
    $Headers = Invoke-WebRequestWrapper @params

    If ($Null -ne $Headers) {
        # Match filename
        $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchVersion).Captures.Value
            Architecture = Get-Architecture -String $Filename
            Date         = $Headers['Last-Modified'] | Select-Object -First 1
            Size         = $Headers['Content-Length'] | Select-Object -First 1
            Filename     = $Filename
            URI          = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
