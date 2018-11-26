# Get latest version and download latest Greenshot release via GitHub API

# GitHub API to query for Greenshot repository
$repo = "greenshot/greenshot"
$releases = "https://api.github.com/repos/$repo/releases"

# Query the Greenshot repository for releases, keeping the latest release
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$latestRelease = (Invoke-WebRequest -Uri $releases -UseBasicParsing | ConvertFrom-Json | `
    Where-Object { $_.prelease -eq $False })[0]

# Latest version number 'Greenshot-RELEASE-1.2.10.6'
$latestVersion = $latestRelease.tag_name
Write-Output $latestVersion

# Array of releases and downloaded
$releases = $latestRelease.assets | Where-Object { $_.name -like "Greenshot*" } | `
    Select-Object name, browser_download_url
Write-Output $releases
