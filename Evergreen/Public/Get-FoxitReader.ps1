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

        # Convert JSON
        try {
            $PackageJson = $Content | ConvertFrom-Json
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert to JSON."
            Break
        }

        # Grab latest version
        $Version = ($PackageJson.package_info.version | Sort-Object { [Version]$_ } -Descending) | Select-Object -First 1

        ForEach ($language in $PackageJson.package_info.language) {
            
            # Build the download URL
            $Uri = $res.Get.DownloadUri -replace "#Version", $Version
            $Uri = (($Uri -replace "#Platform", $platform) -replace "#Language", $language) -replace "#Package", $PackageJson.package_info.type[0]
            
            # Follow the download link which will return a 301/302
            $redirectUrl = Resolve-RedirectedUri -Uri $Uri
            #$redirectUrl = (Resolve-Uri -Uri $Uri).ResponseUri.AbsoluteUri
            
            # Construct the output; Return the custom object to the pipeline
            If ($Null -ne $redirectUrl) {
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Date     = ConvertTo-DateTime -DateTime $PackageJson.package_info.release -Pattern $res.Get.DateTimePattern
                    #Size     = $PackageJson.package_info.size
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
