
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Uri = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$tempFile = New-TemporaryFile

try {
    $params = @{
        Uri             = $Uri
        Method          = "Get"
        ContentType     = "application/vnd.github.v3+json"
        UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        UseBasicParsing = $true
        PassThru        = $true
        OutFile         = $tempFile
    }
    $response = Invoke-RestMethod @params
}
catch [System.Net.WebException] {
    Throw ([System.String]::Format("Error : {0}", $_.Exception.Response.StatusCode))
    Get-Content $tempFile
    Break
}
catch {
    Throw ([System.String]::Format("Error : {0}", $_.Exception.Response.StatusCode))
    Get-Content $tempFile
    Break
}

$response
