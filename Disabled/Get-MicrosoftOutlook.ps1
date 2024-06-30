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

    # Read the update feed
    $params = @{
        Uri = $res.Get.Update.Uri
        Raw = $true
    }
    $Update = Invoke-EvergreenWebRequest @params
    if ($null -ne $Update) {

        # Match version number
        $Version = [RegEx]::Match($Update[-1].Split(" ")[1], $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

        # Build the output object and output object to the pipeline
        $Url = $res.Get.Download.Uri.Zip -replace "#installer", $Update[-1].Split(" ")[1]
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Sha1Hash = $Update[-1].Split(" ")[0]
            Size     = $Update[-1].Split(" ")[2]
            Type     = Get-FileType -File $Url
            URI      = $Url
        }
        Write-Output -InputObject $PSObject

        # Build the output object for setup.exe
        $Url = (Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri.Exe).ResponseUri.AbsoluteUri
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Sha1Hash = "Unknown"
            Size     = "Unknown"
            Type     = Get-FileType -File $Url
            URI      = $Url
        }
        Write-Output -InputObject $PSObject
    }
}
