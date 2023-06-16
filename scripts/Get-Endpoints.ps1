function Get-ApplicationEndpoint {
    <#
        Retrieve the list of endpoints for a given application from the Evergreen API
        for input into firewall rules
    #>
    [Parameter()]
    [System.String[]] $Apps = @("MicrosoftWvdRtcService",
        "MicrosoftWvdMultimediaRedirection",
        "MicrosoftFSLogixApps",
        "Microsoft.NET",
        "MicrosoftEdge",
        "MicrosoftOneDrive",
        "MicrosoftTeams",
        "Microsoft365Apps",
        "AdobeAcrobatReaderDC",
        "RemoteDisplayAnalyzer")

    $Versions = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/versions"
    $Versions | Where-Object { $_.Application -in $Apps } | Select-Object -ExpandProperty "Endpoints" -Unique | Write-Output

    $Downloads = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/downloads"
    $Downloads | Where-Object { $_.Application -in $Apps } | Select-Object -ExpandProperty "Endpoints" -Unique | Write-Output
}

Get-ApplicationEndpoint | Select-Object -Unique
