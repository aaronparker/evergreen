# Need to find the correct query to send to the host
$tempFile = New-TemporaryFile
$Uri = "https://autoupdate.geo.opera.com/"
$Headers = @{
    "Connection" = "Keep-Alive"
}

try {
    $params = @{
        Uri                  = $Uri
        UserAgent            = "Opera autoupdate agent"
        Headers              = $Headers
        SkipCertificateCheck = $True
        Method               = "Head"
        SslProtocol          = "Tls13"
        UseBasicParsing      = $True
        OutFile              = $tempFile
        PassThru             = $True
        ErrorAction          = "SilentlyContinue"
    }
    # Call Invoke-WebRequest
    Invoke-WebRequest @params
}
catch {
    Throw $_
}
Get-Content -Path $tempFile
