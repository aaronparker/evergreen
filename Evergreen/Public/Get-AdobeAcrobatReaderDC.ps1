Function Get-AdobeAcrobatReaderDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat Reader DC Continuous track installers.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-AdobeAcrobatReaderDC

            Description:
            Returns an array with version, installer type, language and download URL for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Installer downloads
    ForEach ($platform in $res.Get.Download.Platforms) {
        ForEach ($language in $res.Get.Download.Languages) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Searching download language: [$language]."
            $Uri = $res.Get.Download.Uri -replace "#Platform", $platform.platform_type
            $Uri = $Uri -replace "#Dist", $platform.platform_dist
            $Uri = $Uri -replace "#Language", $language
            $Uri = $Uri -replace "#Arch", $platform.platform_arch
            $Uri = $Uri -replace " ", "%20"
            $iwcParams = @{
                Uri             = $Uri
                Headers         = $res.Get.Download.Headers
                UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            # TODO: revert back to Invoke-WebRequestWrapper
            #$Content = Invoke-WebRequestWrapper @iwcParams
            $Content = Invoke-WebRequest @iwcParams

            If ($Null -ne $Content) {
                #$ContentFromJson = $Content | ConvertFrom-Json
                $ContentFromJson = $Content.Content | ConvertFrom-Json
                
                # Check properties if multiple values returned
                If ($ContentFromJson.version.Count -eq 1) { $Version = $ContentFromJson.Version } Else { $Version = $ContentFromJson.Version | Select-Object -First 1 }
                If ($ContentFromJson.download_url.Count -eq 1) { $downloadURI = $ContentFromJson.download_url } Else { $downloadURI = $ContentFromJson.download_url | Select-Object -First 1 }
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Type     = "Installer"
                    Language = $language
                    URI      = $downloadURI
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    #endregion

    #region Update downloads
    $iwcParams = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-WebRequestWrapper @iwcParams

    # Construct update download list
    If ($Null -ne $Content) {
        
        ForEach ($update in $res.Get.Download.Updates.GetEnumerator()) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Searching updates: [$($update.Name)]."

            # Output objects
            $PSObject = [PSCustomObject] @{
                Version  = $Content
                Type     = "Updater"
                Language = $update.Name
                URI      = $res.Get.Download.Updates[$update.key] -replace $res.Get.Download.ReplaceText, ($Content.Replace(".", ""))
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
    #endregion
}
