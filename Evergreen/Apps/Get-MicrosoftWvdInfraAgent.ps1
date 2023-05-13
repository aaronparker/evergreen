function Get-MicrosoftWvdInfraAgent {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Windows Virtual Desktop Infrastructure agent.

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
        Uri          = $res.Get.Download.Uri
        Method       = "Head"
        ReturnObject = "Headers"
    }
    $Content = Invoke-WebRequestWrapper @params

    if ($null -ne $Content) {

        # Match filename
        $Filename = [RegEx]::Match($Content.'Content-Disposition', $res.Get.Download.MatchFilename).Captures.Groups[1].Value

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = [RegEx]::Match($Content.'Content-Disposition', $res.Get.Download.MatchVersion).Captures.Value
            Architecture = Get-Architecture -String $Filename
            Date         = $Content.'Last-Modified'[0]
            Filename     = $Filename
            URI          = $res.Get.Download.Uri
        }
        #if ($null -ne $Content.'Content-Length') { $PSObject | Add-Member -Name 'Size' -Type "NoteProperty" -Value $Content.'Content-Length'[0] }
        Write-Output -InputObject $PSObject
    }
}
