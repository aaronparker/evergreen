function Get-deviceTRUST {
    <#
        .SYNOPSIS
            Get the current version and download URLs for deviceTRUST.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the update URI
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Updates = Invoke-EvergreenRestMethod @params

    # Build the output object
    $WindowsUpdates = $Updates | Where-Object { $_.Platform -eq "Windows" }

    foreach ($Type in ($WindowsUpdates.Type | Select-Object -Unique)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): build output for: $Type."

        $Filtered = $WindowsUpdates | Where-Object { $_.Type -eq $Type }
        $Latest = $Filtered | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): found version: $($Latest.Version)."

        $PSObject = [PSCustomObject] @{
            Version  = $Latest.Version
            Platform = $Latest.Platform
            Type     = $Latest.Type
            Name     = $Latest.Name
            URI      = $Latest.URL
        }
        Write-Output -InputObject $PSObject
    }
}
