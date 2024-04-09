# Output GitHub rate limit
<#
    .SYNOPSIS
        Output GitHub API request window
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[OutputType()]
param ()

try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $params = @{
        ContentType        = "application/vnd.github.v3+json"
        ErrorAction        = "SilentlyContinue"
        Headers            = @{ Authorization = "token $($env:GITHUB_TOKEN)" }
        MaximumRedirection = 0
        DisableKeepAlive   = $true
        UseBasicParsing    = $true
        UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        Uri                = "https://api.github.com/rate_limit"
    }
    $GitHubRate = Invoke-RestMethod @params
}
catch {
    Write-Error -Message $_.Exception.Message
}
Write-Host ""
Write-Host "We have $($GitHubRate.rate.remaining) requests left to the GitHub API in this window."
$ResetWindow = [System.TimeZone]::CurrentTimeZone.ToLocalTime(([System.DateTime]'1/1/1970').AddSeconds($GitHubRate.rate.reset))
$TargetTZone = [System.TimeZoneInfo]::GetSystemTimeZones() | Where-Object { $_.Id -match "Australia/Melbourne*|AUS Eastern Standard Time*" } | Select-Object -First 1
$MelbourneTime = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId(($ResetWindow), $TargetTZone.Id)
Write-Host "GitHub rate limit window resets at: $($MelbourneTime.ToShortDateString()) $($MelbourneTime.ToShortTimeString()) AEST."
Write-Host ""
