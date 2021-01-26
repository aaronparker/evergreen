Function Invoke-WebRequestWrapper {
    <#
        .SYNOPSIS
            Validate and return content from Invoke-WebRequest for reading URLs
            Enables normalisation for all public functions and across PowerShell/Windows PowerShell
            Some validation of $Uri is expected before passing to this function

            TODO: Add proxy support
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ContentType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Headers,

        [Parameter()]
        [ValidateSet("Default", "Get", "Head", "Post")]
        [System.String] $Method = "Default",

        [Parameter()]
        [ValidateSet("Default", "Tls", "Tls11", "Tls12", "Tls13")]
        [System.String] $SslProtocol = "Tls12",

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Raw,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $SkipCertificateCheck
    )

    # Disable the Invoke-WebRequest progress bar for faster downloads
    If ($PSBoundParameters.ContainsKey('Verbose')) {
        $ProgressPreference = [System.Management.Automation.ActionPreference]::Continue
    }
    Else {
        $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    }

    # PowerShell 5.1: Trust certificate used by the remote server (typically self-sign certs)
    # PowerShell Core will use -SkipCertificateCheck
    If (($SkipCertificateCheck.IsPresent) -and -not(Test-PSCore)) {
        Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    }

    # Use TLS for connections
    If (($SslProtocol.IsPresent) -and -not(Test-PSCore)) {
        If ($SslProtocol -eq "Tls13") {
            $SslProtocol = "Tls12"
            Write-Warning -Message "$($MyInvocation.MyCommand): Defaulting back to TLS1.2."
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$SslProtocol
    }

    # Call Invoke-WebRequest
    try {
        # Set core parameters
        $iwrParams = @{
            ErrorAction     = "Stop"
            Uri             = $Uri
            UseBasicParsing = $True
            UserAgent       = $UserAgent
        }

        # Set additional parameters
        If ($ContentType.IsPresent) {
            $iwrParams.ContentType = $ContentType
        }
        If ($Headers.IsPresent) {
            $iwrParams.Headers = $Headers
        }
        If (($SkipCertificateCheck.IsPresent) -and (Test-PSCore)) {
            $iwrParams.SkipCertificateCheck = $True
        }
        If (($SslProtocol.IsPresent) -and (Test-PSCore)) {
            $iwrParams.SslProtocol = $SslProtocol
        }
        If ($Raw.IsPresent) {
            $tempFile = New-TemporaryFile
            Write-Verbose -Message "$($MyInvocation.MyCommand): Using temp file $tempFile."
            $iwrParams.OutFile = $tempFile
        }

        ForEach ($item in $iwrParams.GetEnumerator()) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Invoke-WebRequest parameter: [$($item.name): $($item.value)]."
        }
        $Response = Invoke-WebRequest @iwrParams
    }
    catch {
        Throw $_
        Break
    }
    finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Response: [$($Response.StatusCode)]."
        Write-Verbose -Message "$($MyInvocation.MyCommand): Content type: [$($Response.Headers.'Content-Type')]."

        # Output content from the response
        If ($Raw.IsPresent) {
            $Content = Get-Content -Path $TempFile
        }
        Else {
            $Content = $Response.Content 
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand): Returning object of length: [$($Content.Length)]."
        Write-Output -InputObject $Content
    }
}
