Function Get-PiriformCCleanerFree {
    <#
        .SYNOPSIS
            Returns the the latest Piriform CCleaner Free version number and download URI.

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

    $params = @{
        Uri       = $res.Get.Update.Uri
        UserAgent = $res.Get.Update.UserAgent
    }
    $Update = Invoke-RestMethodWrapper @params

    # Build object and output to the pipeline
    if ($null -ne $Update) {

        # Grab the download link headers to find the file name
        $params = @{
            Uri          = $res.Get.Download.Uri
            Method       = "Head"
            ReturnObject = "Headers"
        }
        $Headers = Invoke-WebRequestWrapper @params
        $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

        $PSObject = [PSCustomObject] @{
            Version  = ($Update -split "\|")[2]
            Filename = $Filename
            URI      = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
