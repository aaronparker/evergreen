Function Get-deviceTRUST {
    <#
        .SYNOPSIS
            Get the current version and download URLs for deviceTRUST.

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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Get the update URI
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Updates = Invoke-RestMethodWrapper @params
    ForEach ($item in $Updates) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): build object for: $($item.Name)."
        $PSObject = [PSCustomObject] @{
            Version  = $item.Version
            Platform = $item.Platform
            Type     = $item.Type
            Name     = $item.Name
            URI      = $item.URL
        }
        Write-Output -InputObject $PSObject
    }
}
