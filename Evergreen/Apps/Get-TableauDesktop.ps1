Function Get-TableauDesktop {
    <#
        .SYNOPSIS
            Get the current version and download URL for Tableau Desktop.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
            based on Get-TelerikFiddlerEverywhere.ps1
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    $Response = Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri

    If ($Null -ne $Response) {

        # Extract the version information from the uri
        try {
            $Version = [RegEx]::Match($Response.ResponseUri.LocalPath, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to extract the version information from the uri."
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Version.Replace('-', '.')
            URI     = $Response.ResponseUri.AbsoluteUri
        }
        Write-Output -InputObject $PSObject
    }
}
