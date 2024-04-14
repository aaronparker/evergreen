# function Get-ApplicationEndpoint {
    <#
        Retrieve the list of endpoints for a given application from the Evergreen API
        for input into firewall rules
    #>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [Parameter(Position = 0,
        ValueFromPipeline)]
    [System.String[]] $Apps = @(
        "MicrosoftWvdRtcService",
        "MicrosoftWvdMultimediaRedirection",
        "MicrosoftFSLogixApps",
        "Microsoft.NET",
        "MicrosoftEdge",
        "MicrosoftOneDrive",
        "MicrosoftTeams",
        "Microsoft365Apps",
        "AdobeAcrobatReaderDC",
        "RemoteDisplayAnalyzer")
)

begin {
    $Versions = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/versions"
    $Downloads = Invoke-RestMethod -Uri "https://evergreen-api.stealthpuppy.com/endpoints/downloads"
}
process {
    $Versions | Where-Object { $_.Application -in $Apps } | Select-Object -ExpandProperty "Endpoints" -Unique | Write-Output
    $Downloads | Where-Object { $_.Application -in $Apps } | Select-Object -ExpandProperty "Endpoints" -Unique | Write-Output
}
# }

# Get-ApplicationEndpoint | Select-Object -Unique
