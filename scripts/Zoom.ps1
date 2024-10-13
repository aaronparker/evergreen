$params = @{
    Uri             = "https://zoom.us/releasenotes"
    Method          = "POST"
    Headers         = @{
        "accept" = "*/*"
    }
    Form            = @{
        "cv"           = "6.2.0.46690"
        "os"           = "Win11"
        "type"         = "manual"
        "upgrade64Bit" = "1"
    }
    ContentType     = "multipart/form-data"
    UserAgent       = "Mozilla/5.0 (ZOOM.Win 10.0 x64)"
    UseBasicParsing = $true
    ErrorAction     = "Continue"
}
Invoke-RestMethod @params

$path = "/Users/aaron/Temp/file.txt"

$binaryReader = New-Object System.IO.BinaryReader([System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite))

