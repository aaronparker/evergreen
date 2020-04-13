Function Invoke-WebContent {
    <#
        .SYNOPSIS
            Return content from Invoke-WebRequest.
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
        [System.Management.Automation.SwitchParameter] $TrustCertificate
    )

    # Use TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Verbose -Message "$($MyInvocation.MyCommand): reading: $Uri."

    # Disable the Invoke-WebRequest progress bar for faster downloads
    If ($PSBoundParameters.ContainsKey('Verbose')) {
        $ProgressPreference = "Continue"
    }
    Else {
        $ProgressPreference = "SilentlyContinue"
    }

    # Set ErrorAction
    If ($script:resourceStrings.Preferences.ErrorAction) {
        $errorAction = $script:resourceStrings.Preferences.ErrorAction
    }
    Else {
        $errorAction = "SilentlyContinue"
    }

    If ($TrustCertificate.IsPresent) {
        If (Test-PSCore) {
            Write-Warning -Message "$($MyInvocation.MyCommand): Running PowerShell Core. Skipping System.Security.Cryptography.X509Certificates."
        }
        Else {
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
    }

    try {
        If ($Raw.IsPresent) {
            $tempFile = New-TemporaryFile
            Write-Verbose -Message "$($MyInvocation.MyCommand): Using temp file $tempFile]."
            $iwrParams = @{
                Uri             = $Uri
                OutFile         = $tempFile
                UserAgent       = $UserAgent
                UseBasicParsing = $True
                ErrorAction     = $errorAction
            }
            If ($ContentType.IsPresent) {
                $iwrParams.ContentType = $ContentType
            }
            If ($Headers.IsPresent) {
                $iwrParams.Headers = $Headers
            }
            $Response = Invoke-WebRequest @iwrParams
            $Content = Get-Content -Path $TempFile
        }
        Else {
            $iwrParams = @{
                Uri             = $Uri
                UserAgent       = $UserAgent
                UseBasicParsing = $True
                ErrorAction     = $errorAction
            }
            If ($ContentType.IsPresent) {
                $iwrParams.ContentType = $ContentType
            }
            If ($Headers.IsPresent) {
                $iwrParams.Headers = $Headers
            }
            $Response = Invoke-WebRequest @iwrParams
            $Content = $Response.Content
        }
    }
    catch [System.Net.WebException] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $Uri."
        Write-Warning -Message ([string]::Format("Error : {0}", $_.Exception.Message))
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $Uri."
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to invoke request to: $Uri."
    }
    finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Returning object of length [$($Content.Length)]."
        Write-Output -InputObject $Content
    }
}
