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
        # $Filename = [Regex]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

        # Match filename
        #$Filename = [RegEx]::Match($Headers.'Content-Disposition', $res.Get.Download.MatchFilename).Captures.Groups[1].Value
        $FileName = $Headers.'Content-Disposition'.Split("=")[-1]
        if ($null -ne $Filename) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found filename: $Filename."
        }
        else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to match filename from '$($Headers.'Content-Disposition')'."
        }

        # Match version
        $Version = [RegEx]::Match($FileName, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
        if ($null -ne $Version) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."
        }
        else {
            $Version = [RegEx]::Match($Headers.'Content-Disposition', $res.Get.Download.MatchVersionFallback).Captures.Groups[1].Value
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Date         = ConvertTo-DateTime -DateTime $($Headers.'Last-Modified' | Select-Object -First 1) -Pattern $res.Get.Download.DateFormat
            Architecture = Get-Architecture -String $Filename
            Filename     = $Filename
            URI          = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
