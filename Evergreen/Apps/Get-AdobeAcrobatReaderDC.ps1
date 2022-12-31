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
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    #region Installer downloads
    foreach ($language in $res.Get.Update.Languages.GetEnumerator()) {

        Write-Verbose -Message "$($MyInvocation.MyCommand): Searching updates for language: $($language.Name)."
        $params = @{
            Uri = $res.Get.Update.Uri -replace "#Language", $language.Name
        }
        $UpdateContent = Invoke-RestMethodWrapper @params

        if ($Null -ne $UpdateContent) {
            foreach ($item in $UpdateContent.products.reader) {

                $LanguageFullName = $($res.Get.Update.Languages[$language.Key])
                Write-Verbose -Message "$($MyInvocation.MyCommand): Searching downloads for language: $LanguageFullName, $($language.Name)."
                $params = @{
                    Uri = $res.Get.Download.Uri -replace "#DisplayName", $item.displayName -replace "#ShortLanguage", $language.Name -replace " ", "%20"
                }
                $DownloadContent = Invoke-RestMethodWrapper @params

                if ($null -ne $DownloadContent) {
                    $PSObject = [PSCustomObject] @{
                        Version      = $item.version
                        Language     = $LanguageFullName
                        Architecture = Get-Architecture -String $DownloadContent.downloadURL
                        Name         = $item.displayName
                        URI          = $DownloadContent.downloadURL
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    #endregion
}
