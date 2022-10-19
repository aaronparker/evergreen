function Get-MicrosoftOutlook {
    <#
        .SYNOPSIS
            Returns the available Microsoft Outlook versions and download URIs.

        .NOTES
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

    # Read the JSON and convert to a PowerShell object. Return the release version of Teams
    $params = @{
        Uri = $res.Get.Update.Uri
        Raw = $True
    }
    $Update = Invoke-WebRequestWrapper @params

    # Read the JSON and build an array of platform, channel, version
    if ($Null -ne $Update) {

        # Match version number
        $Version = [RegEx]::Match($Update[-1].Split(" ")[1], $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

        # Build the output object and output object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Sha1Hash = $Update[-1].Split(" ")[0]
            Size     = $Update[-1].Split(" ")[2]
            URI      = $res.Get.Download.Uri -replace "#installer", $Update[-1].Split(" ")[1]
        }
        Write-Output -InputObject $PSObject
    }
}
