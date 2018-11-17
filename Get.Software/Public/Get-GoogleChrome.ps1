Function Get-GoogleChromeVersion {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False)]
        [string] $Uri = "https://omahaproxy.appspot.com/all.json",

        [Parameter(Mandatory = $False)]
        [ValidateSet('win', 'win64', 'mac', 'linux', 'ios', 'cros', 'android', 'webview')]
        [string] $Platform = "win",

        [Parameter(Mandatory = $False)]
        [ValidateSet('stable', 'beta', 'dev', 'canary', 'canary_asan')]
        [string] $Channel = "stable"
    )

    # Read the JSON and convert to a PowerShell object. Return the current release version of Chrome
    $chromeVersions = (Invoke-WebRequest -uri $Uri).Content | ConvertFrom-Json
    $output = (($chromeVersions | Where-Object { $_.os -eq $Platform }).versions | `
            Where-Object { $_.channel -eq $Channel }).current_version
    Write-Output $output
}