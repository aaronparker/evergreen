Function Get-AdobeAcrobatProStdDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat Standard and Pro DC Continuous track updates.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Evergreen
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    #region Installer downloads
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-EvergreenRestMethod @params

    # Construct update download list
    if ($Null -ne $Content) {

        # Build the object
        foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {
            foreach ($Sku in $res.Get.Download.Skus) {
                $PSObject = [PSCustomObject] @{
                    Version      = $Content.products.reader[0].version
                    Architecture = $Architecture.Name
                    Sku          = $Sku
                    URI          = $res.Get.Download.Uri[$Architecture.Key]
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion
}
