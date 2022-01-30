Function Get-PaintDotNet {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Paint.NET tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the Paint.NET updates feed
    $Content = Invoke-WebRequestWrapper -Uri $res.Get.Uri
    If ($Null -ne $Content) {

        # Convert the content from string data
        $Data = $Content | ConvertFrom-StringData

        # Build the output object
        ForEach ($url in ($Data.("$($Data.StableVersions)$($res.Get.UrlProperty)") -split $res.Get.UrlDelimiter)) {
            $PSObject = [PSCustomObject] @{
                Version = $Data.($res.Get.VersionProperty)
                URI     = $url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
