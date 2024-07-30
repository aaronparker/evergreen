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

        # Get the installer display names for the specified language
        Write-Verbose -Message "$($MyInvocation.MyCommand): Searching updates for language: $($language.Name)."
        $params = @{
            Uri = $res.Get.Update.Uri -replace "#Language", $language.Name
        }
        $UpdateContent = Invoke-EvergreenRestMethod @params

        if ($null -ne $UpdateContent) {
            foreach ($Product in $UpdateContent.products.reader) {

                # Search for downloads for each display name returned for the language
                $LanguageFullName = $($res.Get.Update.Languages[$language.Key])
                Write-Verbose -Message "$($MyInvocation.MyCommand): Searching downloads for language: $LanguageFullName, $($language.Name)."
                $params = @{
                    Uri = $res.Get.Download.Uri -replace "#DisplayName", $Product.displayName -replace "#ShortLanguage", $language.Name -replace " ", "%20"
                }
                $DownloadContent = Invoke-EvergreenRestMethod @params

                # Build the output object
                if ($null -ne $DownloadContent) {
                    $PSObject = [PSCustomObject] @{
                        Version      = $Product.version
                        Language     = $LanguageFullName
                        Size         = [System.Int32]$Product.fileSize
                        Architecture = Get-Architecture -String $DownloadContent.downloadURL
                        #Name         = $Product.displayName
                        URI          = $DownloadContent.downloadURL
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    #endregion
}
