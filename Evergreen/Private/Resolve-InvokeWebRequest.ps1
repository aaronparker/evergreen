Function Resolve-InvokeWebRequest {
    <#
        .SYNOPSIS
            Resolve a URL that returns a 301/302 response and returns the redirected URL
            Uses Invoke-WebRequest to find 301/302 headers and return the ResponseUri
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
        ErrorAction        = "SilentlyContinue"
        MaximumRedirection = 0
        Uri                = $Uri
        UseBasicParsing    = $True
        UserAgent          = $UserAgent
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving URI: [$Uri]."
    ForEach ($item in $iwrParams.GetEnumerator()) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Invoke-RestMethod parameter: [$($item.name): $($item.value)]."
    }

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
            Throw $_
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
