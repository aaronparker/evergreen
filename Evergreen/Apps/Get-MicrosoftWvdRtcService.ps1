function Get-MicrosoftWvdRtcService {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop WebRTC Redirector service.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Grab the download link headers to find the file name
    $params = @{
        Uri          = $res.Get.Download.Uri
        Method       = "Head"
        ReturnObject = "Headers"
    }
    $Headers = Invoke-EvergreenWebRequest @params
    if ($null -ne $Headers) {

        # Match filename
        $Filename = [Regex]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = [Regex]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchVersion).Captures.Value
            Date         = $Headers['Last-Modified'] | Select-Object -First 1
            Size         = $Headers['Content-Length'] | Select-Object -First 1
            Architecture = Get-Architecture -String $Filename
            Filename     = $Filename
            URI          = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
