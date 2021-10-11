Function Get-GhislerTotalCommander {
    <#
        .SYNOPSIS
            Returns the available Ghisler TotalCommander versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Name = $res.Get.Update.Uri
        Type = $res.Get.Update.DnsType
    }
    $Response = Resolve-DnsNameWrapper @params
    If ($Null -ne $Response) {

        try {
            $Version = ([RegEx]$res.Get.Update.MatchVersion).Match($Response.Strings).Groups.Value
            $VersionString = $Version.ToString() -replace "\.", ""
        }
        catch {
            $Version = "Unknown"
        }

        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $item.Name
                URI          = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $VersionString
            }
            Write-Output -InputObject $PSObject
        }
    }
}
