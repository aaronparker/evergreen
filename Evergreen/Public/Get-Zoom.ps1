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
        Write-Warning "This function is currently unsupported on PowerShell Core. Please use Windows PowerShell."
    }
    Else {
        # Request the download URL to grab the header that includes the URL to the download
        # Handling HTTP 302 on PowerShell Core fails
        try {
            $iwrParams = @{
                Uri                = $script:resourceStrings.Applications.Zoom.Uri
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
            $r.Headers.Location -match $script:resourceStrings.Applications.Zoom.MatchVersion | Out-Null
            $Version = $Matches[0]
            If ($request.StatusCode -ge 300 -and $request.StatusCode -lt 400) {
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    URI      = $r.Headers.Location
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
