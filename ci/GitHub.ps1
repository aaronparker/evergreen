# Output GitHub rate limit
<#
    .SYNOPSIS
        Output GitHub API request window
#>
[OutputType()]
param ()

try {
    $SslProtocol = "Tls12"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$SslProtocol
    $params = @{
        ContentType        = "application/vnd.github.v3+json"
        ErrorAction        = "SilentlyContinue"
        MaximumRedirection = 0
        DisableKeepAlive   = $true
        UseBasicParsing    = $true
        UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        Uri                = "https://api.github.com/rate_limit"
    }
    $GitHubRate = Invoke-RestMethod @params
}
catch {
}
Write-Host "We have $($GitHubRate.rate.remaining) requests left to the GitHub API in this window."
$ResetWindow = [System.TimeZone]::CurrentTimeZone.ToLocalTime(([System.DateTime]'1/1/1970').AddSeconds($GitHubRate.rate.reset))
Write-Host "GitHub rate limit window resets at: $($ResetWindow.ToShortDateString()) $($ResetWindow.ToShortTimeString())."
