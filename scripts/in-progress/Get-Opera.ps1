# Need to find the correct query to send to the host
$Uri = "https://autoupdate.geo.opera.com/"
$Headers = @{
    "Connection" = "Keep-Alive"
}

$params = @{
    Uri                  = $Uri
    UserAgent            = "Opera autoupdate agent"
    UseBasicParsing      = $True
    ErrorAction          = "SilentlyContinue"
    Headers              = $Headers
    SkipCertificateCheck = $True
}
# Call Invoke-WebRequest
Invoke-WebRequest @params
