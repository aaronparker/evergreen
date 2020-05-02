Function Get-FoxitReader {
    <#
        .SYNOPSIS
            Get the current version and download URL for Foxit Reader.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-CitrixFoxitReader

            Description:
            Returns the current version and download URL Foxit Reader.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Get Foxit Reader details
    ForEach ($platform in $res.Get.Platforms) {
        
        # Query the Foxit Reader package download form to get the JSON
        $Uri = $res.Get.Uri -replace "#Platform", $platform
        $Content = Invoke-WebContent -Uri $Uri

        # Grab values
        $PackageJson = $Content | ConvertFrom-Json
        $Languages = $PackageJson.package_info.language
        $Version = ($PackageJson.package_info.version | Sort-Object -Descending) | Select-Object -First 1

        ForEach ($language in $Languages) {
            
            # Build the download URL
            $Uri = $res.Get.DownloadUri -replace "#Version", $Version
            $Uri = (($Uri -replace "#Platform", $platform) -replace "#Language", $language) -replace "#Package", $PackageJson.package_info.type[0]
            
            # Follow the download link which will return a 301/302
            $redirectUrl = Resolve-RedirectedUri -Uri $Uri
            If ($Null -ne $redirectUrl) {

                # Construct the output; Return the custom object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Date     = ConvertTo-DateTime -DateTime $PackageJson.package_info.release -Pattern $res.Get.DateTimePattern
                    Size     = $PackageJson.package_info.size
                    Language = $language
                    URI      = $redirectUrl
                }
                Write-Output -InputObject $PSObject
            }
            Else {
                Write-Warning -Message "Failed to return a useable URL from $Uri."
            }
        }
    }
    #endregion
}
