
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
$Uri = "https://api.github.com/repos/git-for-windows/git1/releases/latest"
$tempFile = New-TemporaryFile

$params = @{
    Uri             = $Uri
    Method          = "Get"
    ContentType     = "application/vnd.github.v3+json"
    UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    UseBasicParsing = $true
    PassThru        = $true
    OutFile         = $tempFile
    ErrorAction     = "Stop"
}
Invoke-RestMethod @params
