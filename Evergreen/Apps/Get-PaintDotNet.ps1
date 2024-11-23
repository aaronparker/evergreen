function Get-PaintDotNet {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Paint.NET tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the Paint.NET updates feed
    $Content = Invoke-EvergreenWebRequest -Uri $res.Get.Uri
    if ($null -ne $Content) {

        # Convert the content from string data
        $Data = $Content | ConvertFrom-StringData
        $Key = $Data.Keys | Where-Object { $_ -match $res.Get.UrlProperty }

        # Build the output object
        foreach ($url in $Data.$Key) {
            $PSObject = [PSCustomObject] @{
                Version = $Data.($res.Get.VersionProperty)
                URI     = $url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
