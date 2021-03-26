$Uri = "https://update.libreoffice.org/check.php"
$tempFile = New-TemporaryFile
$iwrParams = @{
    Uri                  = $Uri
    OutFile              = $tempFile
    UserAgent            = "LibreOffice 6.3.2.1 (db810050ff08fd4774137f693d5a01d22f324dfd; Windows; X86_64; )"
    #UserAgent            = "LibreOffice 6.2.7.1 (23edc44b61b830b7d749943e020e96f5a7df63bf; Windows; X86_64; )"
    UseBasicParsing      = $True
    ErrorAction          = "Continue"
    SkipCertificateCheck = $True
}
$Response = Invoke-WebRequest @iwrParams
$Content = Get-Content -Path $TempFile
Write-Output -InputObject $Content
