Function Get-AdobeAcrobat {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat (Standard/Pro) 2020 or DC updates.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

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
                Throw "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri[$item.key])."
            }
        }
    }
    #endregion
}
