function Resolve-InvokeWebRequest {
    <#
        .SYNOPSIS
            Resolve a URL that returns a 301/302 response and returns the redirected URL
            Uses Invoke-WebRequest to find 301/302 headers and return the ResponseUri
    #>
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.Int32] $MaximumRedirection = 0
    )

    # Disable the Invoke-WebRequest progress bar for faster downloads
    if ($PSBoundParameters.ContainsKey("Verbose")) {
        $ProgressPreference = [System.Management.Automation.ActionPreference]::Continue
    }
    else {
        $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    }

    # Build the Invoke-WebRequest parameters; Use ErrorAction:SilentlyContinue to enable the try/catch to work
    $params = @{
        MaximumRedirection = $MaximumRedirection
        Uri                = $Uri
        UseBasicParsing    = $true
        UserAgent          = $UserAgent
        ErrorAction        = "Continue"
    }
    if (Test-ProxyEnv) {
        $params.Proxy = $script:EvergreenProxy
    }
    if (Test-ProxyEnv -Creds) {
        $params.ProxyCredential = $script:EvergreenProxyCreds
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving URI: [$Uri]."

    # Output the parameters when using -Verbose
    foreach ($item in $params.GetEnumerator()) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Invoke-WebRequest parameter: $($item.name): $($item.value)."
    }

    if (Test-PSCore) {
        try {
            # If running PowerShell Core, request URL and catch the response
            Invoke-WebRequest @params | Out-Null
        }
        catch [System.Exception] {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Response: [$($_.Exception.Response.StatusCode) - $($_.Exception.Response.ReasonPhrase)]."
            if ($null -ne $_.Exception.Response.Headers.Location.AbsoluteUri) {
                Write-Output -InputObject $_.Exception.Response.Headers.Location.AbsoluteUri
            }
            else {
                # We can't throw here because we need to capture the error response to return a URL
                Write-Warning -Message "$($MyInvocation.MyCommand): Response: [$($_.Exception.Response.StatusCode) - $($_.Exception.Response.ReasonPhrase)]."
                Write-Warning -Message "$($MyInvocation.MyCommand): For troubleshooting steps see: $($script:resourceStrings.Uri.Info)."
                Write-Error -Message "$($MyInvocation.MyCommand): $($_.Exception.Message)."
            }
        }
    }
    else {
        try {
            # If running Windows PowerShell, request the URL and return the response
            $response = Invoke-WebRequest @params
            Write-Verbose -Message "$($MyInvocation.MyCommand): Response: [$($response.StatusCode) - $($response.StatusDescription)]."
            Write-Output -InputObject $response.Headers.Location
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Error at URI: $Uri."
            Write-Warning -Message "$($MyInvocation.MyCommand): Error encountered: $($_.Exception.Message)."
            Write-Warning -Message "$($MyInvocation.MyCommand): For troubleshooting steps see: $($script:resourceStrings.Uri.Info)."
            throw $_
        }
    }
}
