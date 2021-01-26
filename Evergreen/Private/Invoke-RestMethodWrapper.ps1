Function Invoke-RestMethodWrapper {
    <#
        .SYNOPSIS
            Validate and return content from Invoke-RestMethod for reading update APIs (typically JSON)
            Enables normalisation for all public functions and across PowerShell/Windows PowerShell
            Some validation of $Uri is expected before passing to this function
            Does not support redirection, as this should be handled before sending to this function

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
        [System.String] $ContentType = "application/json; charset=utf-8",

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
        [System.Management.Automation.SwitchParameter] $SkipCertificateCheck
    )

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

    # Call Invoke-RestMethod
    try {
        $irmParams = @{
            ContentType        = $ContentType
            DisableKeepAlive   = $true
            ErrorAction        = "Stop"
            MaximumRedirection = 0
            Uri                = $Uri
            UseBasicParsing    = $true
            UserAgent          = $UserAgent
        }
        If ($Headers.IsPresent) {
            $irmParams.Headers = $Headers
        }
        If ($Method.IsPresent) {
            $irmParams.Method = $Method
        }
        If (($SkipCertificateCheck.IsPresent) -and (Test-PSCore)) {
            $irmParams.SkipCertificateCheck = $True
        }
        If (($SslProtocol.IsPresent) -and (Test-PSCore)) {
            $irmParams.SslProtocol = $SslProtocol
        }

        ForEach ($item in $irmParams.GetEnumerator()) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Invoke-RestMethod parameter: [$($item.name): $($item.value)]."
        }
        $Response = Invoke-RestMethod @irmParams
    }
    catch {
        Throw $_
        Break
    }
    finally {
        Write-Output -InputObject $Response
    }
}
