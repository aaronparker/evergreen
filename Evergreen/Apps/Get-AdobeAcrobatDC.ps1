Function Get-AdobeAcrobatDC {
    <#
        .SYNOPSIS
            Gets the download URLs for Adobe Acrobat Reader DC Continuous track updates.

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
    foreach ($language in $res.Get.Update.Languages) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Searching download language: [$language]."
        $params = @{
            Uri = $($res.Get.Update.Uri -replace "#Language", $language)
            #Headers         = $res.Get.Update.Headers
        }
        $Content = Invoke-EvergreenRestMethod @params

        # Construct update download list
        if ($null -ne $Content) {

            # Format version string
            if ($Content.products.reader.version.count -gt 1) {
                $VersionString = $Content.products.reader.version[0].Replace(".", "").Trim()
                $Version = $Content.products.reader.version[0]
            }
            else {
                $VersionString = $Content.products.reader.version.Replace(".", "").Trim()
                $Version = $Content.products.reader.version
            }
            Write-Verbose -Message "$($MyInvocation.MyCommand): Update found: $($versionString)."

            # Build the output object
            foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {
                foreach ($Url in $res.Get.Download.Uri.($Architecture.Name).GetEnumerator()) {

                    # Construct the URI property
                    $Uri = ($res.Get.Download.Uri.($Architecture.Name)[$Url.key] `
                            -replace $res.Get.Download.ReplaceText.Version, $versionString)

                    # Build the object
                    $PSObject = [PSCustomObject] @{
                        Version      = $Version
                        Type         = $Url.Name
                        Architecture = $Architecture.Name
                        URI          = $Uri
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    #endregion
}
