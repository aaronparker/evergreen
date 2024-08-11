Function Get-Zotero {
    <#
        .SYNOPSIS
            Get the current version and download URL for Zotero.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
            Based on Get-TelerikFiddlerEverywhere.ps1
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Uri in $res.Get.Download.Uri) {
        # Get the latest download
        $Response = Resolve-SystemNetWebRequest -Uri $Uri

        # Construct the output; Return the custom object to the pipeline
        if ($null -ne $Response) {
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($Response.ResponseUri.LocalPath, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                Architecture = Get-Architecture -String $Response.ResponseUri.AbsoluteUri
                Type         = Get-FileType -File $Response.ResponseUri.AbsoluteUri
                URI          = $Response.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
