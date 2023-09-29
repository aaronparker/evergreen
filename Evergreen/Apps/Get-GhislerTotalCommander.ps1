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
            $Value = ([Regex]$res.Get.Update.MatchVersion).Match($Response).Groups.Value
            $Major = $Value.Split(".")[1]
            $Minor = $Value.Split(".")[2]
            if ([System.Int16]$Minor -le 9) {
                $Minor = "0$Minor"
            }
            $Version = "$Major.$Minor"
            $VersionString = "$Major$Minor"
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to find version number."
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
