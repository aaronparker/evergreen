Function Get-AdobeAcrobatProDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat Pro DC Continuous track updaters.

        .DESCRIPTION
            Gets the download URLs for Adobe Acrobat Pro DC Continuous track updaters.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-AdobeAcrobatProDC

            Description:
            Returns an array with version, download URL for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Update downloads
    $iwcParams = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-WebRequestWrapper @iwcParams

    # Construct update download list
    If ($Null -ne $Content) {
        $versionString = $Content.Replace(".", "")
        $PSObject = [PSCustomObject] @{
            Version  = $Content
            Type     = "Updater"
            Language = "Neutral"
            URI      = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $versionString
        }
        Write-Output -InputObject $PSObject
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retreive content from $($res.Get.Update.Uri)."
    }
    #endregion
}
