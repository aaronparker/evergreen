Function Get-AdobeAcrobat {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat (Standard/Pro) 2020 or DC updates.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-AdobeAcrobat

            Description:
            Returns an array with version, download URL for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Alias("Get-AdobeAcrobatProDC")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Update downloads
    ForEach ($Product in $res.Get.Update.Uri.GetEnumerator()) {
        ForEach ($item in $res.Get.Update.Uri.($Product.Name).GetEnumerator()) {

            $params = @{
                Uri         = $res.Get.Update.Uri.($Product.Name)[$item.key]
                ContentType = $res.Get.Update.ContentType
            }
            $Content = Invoke-WebRequestWrapper @params

            # Construct update download list
            If ($Null -ne $Content) {
            
                # Format version string
                $versionString = $Content.Replace(".", "")

                # Build the output object
                ForEach ($Url in $res.Get.Download.Uri.($Product.Name).GetEnumerator()) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $Content
                        Type     = $res.Get.Download.Type
                        Product  = $Product.Name
                        Track    = $item.Name
                        Language = $Url.Name
                        URI      = ($res.Get.Download.Uri.($Product.Name)[$Url.key] -replace $res.Get.Download.ReplaceText.Version, $versionString) -replace $res.Get.Download.ReplaceText.Track, $item.Name
                    }
                    Write-Output -InputObject $PSObject
                }
            }
            Else {
                Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri[$item.key])."
            }
        }
    }
    #endregion
}
