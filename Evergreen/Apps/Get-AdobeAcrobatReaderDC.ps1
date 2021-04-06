Function Get-AdobeAcrobatReaderDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat Reader DC Continuous track installers.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Installer downloads
    ForEach ($language in $res.Get.Download.Languages) {

        Write-Verbose -Message "$($MyInvocation.MyCommand): Searching download language: [$language]."
        $Uri = $res.Get.Download.Uri -replace "#Language", $language
        $params = @{
            Uri             = $Uri
            Headers         = $res.Get.Download.Headers
            UseBasicParsing = $True
            ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
        }
        try {
            #TODO: update Invoke-RestMethodWrapper to support this query correctly
            $Content = Invoke-RestMethod @params
        }
        catch {
            Throw $_
            Break
        }

        If ($Content) {
            ForEach ($item in $Content) {
                $PSObject = [PSCustomObject] @{
                    Version      = $item.Version
                    Language     = $language
                    Architecture = Get-Architecture -String $item.download_url
                    Name         = $item.Name
                    URI          = $item.download_url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion
}
