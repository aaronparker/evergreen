function Invoke-RestMethodWrapper {
    <#
        .SYNOPSIS
            Validate and return content from Invoke-RestMethod for reading update APIs (typically JSON)
            Enables normalisation for all public functions and across PowerShell/Windows PowerShell
            Some validation of $Uri is expected before passing to this function
            Does not support redirection, as this should be handled before sending to this function

            TODO: Add proxy support
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
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
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Body,

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

    # Set ErrorAction value
    if ($PSBoundParameters.ContainsKey("ErrorAction")) {
        $ErrorActionPreference = $ErrorAction
    }
    else {
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Continue
    }

    # PowerShell 5.1: Trust certificate used by the remote server (typically self-sign certs)
    # PowerShell Core will use -SkipCertificateCheck
    if (($SkipCertificateCheck.IsPresent) -and -not(Test-PSCore)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Creating class TrustAllCertsPolicy."
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
        Write-Verbose -Message "$($MyInvocation.MyCommand): Settings Net.SecurityProtocolType to $SslProtocol."
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName "TrustAllCertsPolicy"
    }

    # Use TLS for connections
    if (($SslProtocol.IsPresent) -and -not(Test-PSCore)) {
        if ($SslProtocol -eq "Tls13") {
            $SslProtocol = "Tls12"
            Write-Warning -Message "$($MyInvocation.MyCommand): Defaulting back to TLS1.2."
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$SslProtocol
    }

    # Call Invoke-RestMethod
    $irmParams = @{
        Uri                = $Uri
        ContentType        = $ContentType
        DisableKeepAlive   = $true
        MaximumRedirection = 2
        Method             = $Method
        UseBasicParsing    = $true
        UserAgent          = $UserAgent
    }
    if ($PSBoundParameters.ContainsKey("Headers")) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Adding Headers."
        $irmParams.Headers = $Headers
    }
    if ($PSBoundParameters.ContainsKey("Body")) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Adding Body."
        $irmParams.Body = $Body
    }
    if ($PSBoundParameters.ContainsKey("SkipCertificateCheck") -and (Test-PSCore)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Adding SkipCertificateCheck."
        $irmParams.SkipCertificateCheck = $True
    }
    if ($PSBoundParameters.ContainsKey("SslProtocol") -and (Test-PSCore)) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Adding SslProtocol."
        $irmParams.SslProtocol = $SslProtocol
    }
    if (Test-ProxyEnv) {
        $irmParams.Proxy = $script:EvergreenProxy
    }
    if (Test-ProxyEnv -Creds) {
        $irmParams.ProxyCredential = $script:EvergreenProxyCreds
    }
    foreach ($item in $irmParams.GetEnumerator()) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Invoke-RestMethod parameter: [$($item.name): $($item.value)]."
    }
    try {
        $Response = Invoke-RestMethod @irmParams
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at URI: $Uri."
        Write-Warning -Message "$($MyInvocation.MyCommand): Error encountered: $($_.Exception.Message)."
        Write-Warning -Message "$($MyInvocation.MyCommand): For troubleshooting steps see: $($script:resourceStrings.Uri.Info)."
        Write-Error -Message "$($MyInvocation.MyCommand): $($_.Exception.Message)."
    }
    finally {
        Write-Output -InputObject $Response
    }
}
