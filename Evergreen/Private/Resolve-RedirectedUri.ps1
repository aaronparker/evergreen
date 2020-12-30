Function Resolve-RedirectedUri {
    <#
        .SYNOPSIS
        Resolved a URL that returns a 301/302 response and returns the redirected URL.
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    )

    # Build the Invoke-WebRequest parameters
    $iwrParams = @{
        Uri                = $Uri
        UseBasicParsing    = $True
        MaximumRedirection = 0
        UserAgent          = $UserAgent
        #Method             = "Head"
        ErrorAction        = "SilentlyContinue"
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving URI: [$Uri]."

    If (Test-PSCore) {
        # If running PowerShell Core, request URL and catch the response
        Try {
            Invoke-WebRequest @iwrParams
        }
        Catch [System.Exception] {
            $redirectUrl = $_.Exception.Response.Headers.Location.AbsoluteUri
            Write-Verbose -Message "$($MyInvocation.MyCommand): Response: [$($_.Exception.Response.StatusCode) - $($_.Exception.Response.ReasonPhrase)]."
        }
    }
    Else {
        # If running Windows PowerShell, request the URL and return the response
        Try {
            $response = Invoke-WebRequest @iwrParams
            $redirectUrl = $response.Headers.Location
            Write-Verbose -Message "$($MyInvocation.MyCommand): Response: [$($response.StatusCode) - $($response.StatusDescription)]."
        }
        Catch [System.Exception] {
            Write-Warning -Message ([System.String]::Format("$($MyInvocation.MyCommand): Error : {0}", $_.Exception.Message))
        }
    }

    # Validate and return the resolved URL to the pipeline
    If ($Null -ne $redirectUrl) {
        If ($redirectUrl.GetType() -eq [System.String]) {
            Write-Output -InputObject $redirectUrl
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to resolve correct output type (String)."
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to resolve a redirect at: $Uri."
    }
}
