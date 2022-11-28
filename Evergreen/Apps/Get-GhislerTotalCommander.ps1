function Get-GhislerTotalCommander {
    <#
        .SYNOPSIS
            Returns the available Ghisler TotalCommander versions.

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

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Name = $res.Get.Update.Uri
        Type = $res.Get.Update.DnsType
    }
    $Response = Resolve-DnsNameWrapper @params
    if ($null -ne $Response) {

        try {
            $Value = ([RegEx]$res.Get.Update.MatchVersion).Match($Response).Groups.Value
            $Version = $Value.Split(".")[1,2] -join "."
            $VersionString = $Value.Split(".")[1,2] -join ""
        }
        catch {
            $Version = "Unknown"
            $VersionString = "Unknown"
        }

        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version"
        foreach ($item in $res.Get.Download.Uri.GetEnumerator()) {
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $item.Name
                URI          = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText, $VersionString
            }
            Write-Output -InputObject $PSObject
        }
    }
}
