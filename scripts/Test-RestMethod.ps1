
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Uri = "https://api.github.com/repos/git-for-windows/git1/releases/latest"
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
catch {
    Write-Warning -Message "$($MyInvocation.MyCommand): REST API call to [$Uri] failed with: $($_.Exception.Response.StatusCode)."
    Throw $_
    Break
}

$response
