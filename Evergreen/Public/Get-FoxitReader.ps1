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

    If (Test-PSCore) {
        Write-Warning "This function is currently unsupported on PowerShell Core. Please use Windows PowerShell."
    }
    Else {
        #region Get Foxit Reader details
        ForEach ($platform in $script:resourceStrings.Applications.FoxitReader.Platforms) {
        
            # Query the Foxit Reader package download form to get the JSON
            $Uri = $script:resourceStrings.Applications.FoxitReader.Uri -replace "#Platform", $platform
            $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.FoxitReader.Uri

            # Grab values
            $PackageJson = $Content | ConvertFrom-Json
            $Languages = $PackageJson.package_info.language
            $Version = ($PackageJson.package_info.version | Sort-Object -Descending) | Select-Object -First 1

            ForEach ($language in $Languages) {
            
                # Build the download URL
                $Uri = $script:resourceStrings.Applications.FoxitReader.DownloadUri -replace "#Version", $Version
                $Uri = $Uri -replace "#Platform", $platform
                $Uri = $Uri -replace "#Language", $language
                $Uri = $Uri -replace "#Package", $PackageJson.package_info.type[0]
            
                # Request the download URL to grab the header that includes the URL to the download
                # Handling HTTP 302 on PowerShell Core fails
                try {
                    $iwrParams = @{
                        Uri                = $Uri
                        MaximumRedirection = 0
                        UseBasicParsing    = $True
                        ErrorAction        = "SilentlyContinue"
                    }
                    $request = Invoke-WebRequest @iwrParams
                }
                catch [System.Net.WebException] {
                    Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): failed to invoke request to: $Uri."
                    Throw $_.Exception.Message
                }
                finally {
                    Write-Verbose "Date: $($PackageJson.package_info.release)"
                    If ($request.StatusCode -ge 300 -and $request.StatusCode -lt 400) {
                        $PSObject = [PSCustomObject] @{
                            Version  = $Version
                            #Date     = ([DateTime]::Parse($PackageJson.package_info.release))
                            Date     = $PackageJson.package_info.release
                            Size     = $PackageJson.package_info.size
                            Language = $language
                            URI      = $request.Headers.Location
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
        #endregion
    }
}
