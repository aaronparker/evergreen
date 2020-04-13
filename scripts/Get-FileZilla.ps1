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
$Uri = "https://update.filezilla-project.org/update.php?initial=0&manual=1&osarch=64&osversion=10.0&package=1&platform=x86_64-w64-mingw32&updated=0&version=3.47.2.1"
$Content = (Invoke-WebRequest -URI $Uri -UseBasicParsing -UserAgent "FileZilla/3.47.2.1").Content
$Content | ConvertFrom-Csv -Delimiter " " -Header Channel, Version, URI, Size, HashType, Hash, Signature
