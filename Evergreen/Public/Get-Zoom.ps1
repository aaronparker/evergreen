Function Get-Zoom {    
    <#
        .SYNOPSIS
            Get the current version and download URL for Zoom.

        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Zoom

            Description:
            Returns the current version and download URL for Zoom.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    If (Test-PSCore) {
        Write-Warning -Message "This function is currently unsupported on PowerShell Core. Please use Windows PowerShell."
    }
    Else {
        #region Zoom for Windows clients and plug-ins
        ForEach ($installer in $script:resourceStrings.Applications.Zoom.WindowsUris.GetEnumerator()) {

            # Request the download URL to grab the header that includes the URL to the download
            # Handling HTTP 302 on PowerShell Core fails
            try {
                $iwrParams = @{
                    Uri                = $script:resourceStrings.Applications.Zoom.WindowsUris[$installer.Key]
                    UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
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
                # Match version number from the download URL
                If ($request.Headers.Location -match $script:resourceStrings.Applications.Zoom.MatchVersion) {
                    $Version = $Matches[0]
                }
                Else {
                    $Version = "Unknown"
                }

                If ($request.StatusCode -ge 300 -and $request.StatusCode -lt 400) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $Version
                        Platform = "Windows"
                        Type     = $installer.Name
                        URI      = $request.Headers.Location
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
        #endregion

        #region Zoom for Virtual Desktops (Citrix)
        ForEach ($installer in $script:resourceStrings.Applications.Zoom.CitrixVDIUris.GetEnumerator()) {

            # Request the download URL to grab the header that includes the URL to the download
            # Handling HTTP 302 on PowerShell Core fails
            try {
                $iwrParams = @{
                    Uri                = $script:resourceStrings.Applications.Zoom.CitrixVDIUris[$installer.Key]
                    UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
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
                # Match version number from the download URL
                If ($request.Headers.Location -match $script:resourceStrings.Applications.Zoom.MatchVersion) {
                    $Version = $Matches[0]
                }
                Else {
                    $Version = "Unknown"
                }

                If ($request.StatusCode -ge 300 -and $request.StatusCode -lt 400) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $Version
                        Platform = "Citrix"
                        Type     = $installer.Name
                        URI      = $request.Headers.Location
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
        #endregion

        #region Zoom for Virtual Desktops (VMware)
        ForEach ($installer in $script:resourceStrings.Applications.Zoom.VMwareVDIUris.GetEnumerator()) {

            # Request the download URL to grab the header that includes the URL to the download
            # Handling HTTP 302 on PowerShell Core fails
            try {
                $iwrParams = @{
                    Uri                = $script:resourceStrings.Applications.Zoom.VMwareVDIUris[$installer.Key]
                    UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
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
                # Match version number from the download URL
                If ($request.Headers.Location -match $script:resourceStrings.Applications.Zoom.MatchVersion) {
                    $Version = $Matches[0]
                }
                Else {
                    $Version = "Unknown"
                }

                If ($request.StatusCode -ge 300 -and $request.StatusCode -lt 400) {
                    $PSObject = [PSCustomObject] @{
                        Version  = $Version
                        Platform = "VMware"
                        Type     = $installer.Name
                        URI      = $request.Headers.Location
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
        #endregion
    }
}
