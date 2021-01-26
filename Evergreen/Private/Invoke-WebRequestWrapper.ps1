Function Invoke-WebRequestWrapper {
    <#
        .SYNOPSIS
            Validate and return content from Invoke-WebRequest for reading URLs
            Enables normalisation for all public functions and across PowerShell/Windows PowerShell
            Some validation of $Uri is expected before passing to this function
    #>
    [OutputType([Microsoft.PowerShell.Commands.WebResponseObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $ContentType,

        [Parameter(Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Headers,

        [Parameter(Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $Raw,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $SkipCertificateCheck
    )

    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Verbose -Message "$($MyInvocation.MyCommand): reading: $Uri."

    # Disable the Invoke-WebRequest progress bar for faster downloads
    If ($PSBoundParameters.ContainsKey('Verbose')) {
        $ProgressPreference = [System.Management.Automation.ActionPreference]::Continue
    }
    Else {
        $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    }

    # Set ErrorAction
    If ($script:resourceStrings.Preferences.ErrorAction) {
        $errorAction = $script:resourceStrings.Preferences.ErrorAction
    }
    Else {
        $errorAction = "SilentlyContinue"
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

    try {
        # Set core parameters
        $iwrParams = @{
            Uri             = $Uri
            UserAgent       = $UserAgent
            UseBasicParsing = $True
            ErrorAction     = $errorAction
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
        If ($Raw.IsPresent) {
            $tempFile = New-TemporaryFile
            Write-Verbose -Message "$($MyInvocation.MyCommand): Using temp file $tempFile."
            $iwrParams.OutFile = $tempFile
        }

        # Call Invoke-WebRequest
        $Response = Invoke-WebRequest @iwrParams
    }
    catch [System.Net.WebException] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $Uri."
        Throw ([System.String]::Format("Error : {0}", $_.Exception.Response.StatusCode))
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $Uri."
        Throw ([System.String]::Format("Error : {0}", $_.Exception.Response.StatusCode))
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
