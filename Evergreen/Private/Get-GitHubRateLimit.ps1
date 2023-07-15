function Get-GitHubRateLimit {
    <#
        Check that we aren't rate limited
        https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param ()

    process {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Checking for how many requests to the GitHub API we have left."
        $params = @{
            Uri                = "https://api.github.com/rate_limit"
            ErrorAction        = "Stop"
            MaximumRedirection = 0
            DisableKeepAlive   = $true
            UseBasicParsing    = $true
            UserAgent          = "github-aaronparker-evergreen"
        }

        if (Test-ProxyEnv) {
            $params.Proxy = $script:EvergreenProxy
        }
        if (Test-ProxyEnv -Creds) {
            $params.ProxyCredential = $script:EvergreenProxyCreds
        }
        # If GITHUB_TOKEN or GH_TOKEN exists, let's add that to the API request
        if (Test-Path -Path "env:GITHUB_TOKEN") {
            $params.Headers = @{ Authorization = "token $env:GITHUB_TOKEN" }
        }
        elseif (Test-Path -Path "env:GH_TOKEN") {
            $params.Headers = @{ Authorization = "token $env:GH_TOKEN" }
        }
        $GitHubRate = Invoke-RestMethod @params

        $ResetWindow = [System.TimeZone]::CurrentTimeZone.ToLocalTime(([System.DateTime]'1/1/1970').AddSeconds($GitHubRate.rate.reset))
        Write-Verbose -Message "$($MyInvocation.MyCommand): We have $($GitHubRate.rate.remaining) requests left to the GitHub API in this window."
        Write-Verbose -Message "$($MyInvocation.MyCommand): Rate limit window resets at: $($ResetWindow.ToShortDateString()) $($ResetWindow.ToShortTimeString())."
        if ($GitHubRate.rate.remaining -eq 0) {
            Write-Warning -Message "$($MyInvocation.MyCommand): Requests to GitHub are being rate limited."
        }

        # Output the .rate property
        Write-Output -InputObject $GitHubRate.rate
    }
}
