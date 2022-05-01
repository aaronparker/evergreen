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
    try {
        $params = @{
            Uri = $res.Get.Update.Uri
        }
        $Content = Invoke-RestMethodWrapper @params
    }
    catch {
        throw "$($MyInvocation.MyCommand): $($_.Exception.Message)."
    }

    # Construct update download list
    if ($Null -ne $Content) {

        foreach ($Type in $res.Get.Download.Types) {
            # Build the object
            $PSObject = [PSCustomObject] @{
                Version      = $Content.products.dcPro.version
                Architecture = "x64"
                Type         = $Type
                URI          = $res.Get.Download.Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
    else {
        throw "$($MyInvocation.MyCommand): unable to retrieve content from: $($res.Get.Update.Uri)."
    }
    #endregion
}
