function Get-EvergreenEndpoint {
    <#
        .EXTERNALHELP Evergreen-help.xml

        Retrieve the list of endpoints for a given application from the Evergreen API for input into firewall rules

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
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [System.String[]] $Name
    )

    begin {
        # Get the endpoints for updates/versions source URLs
        $params = @{
            Uri         = "https://evergreen-api.stealthpuppy.com/endpoints/versions"
            ErrorAction = "Stop"
        }
        $Versions = Invoke-RestMethod @params

        # Get the endpoints from the download URLs
        $params = @{
            Uri         = "https://evergreen-api.stealthpuppy.com/endpoints/downloads"
            ErrorAction = "Stop"
        }
        $Downloads = Invoke-RestMethod @params
    }
    process {
        # Output the endpoints by joining the two queries
        $Endpoints = $Versions | ForEach-Object {
            $Application = $_.Application
            [PSCustomObject]@{
                Application = $Application
                Endpoints   = @(($_.Endpoints + ($Downloads | Where-Object { $_.Application -eq $Application }).Endpoints) | Select-Object -Unique)
                Ports       = @(($_.Ports + ($Downloads | Where-Object { $_.Application -eq $Application }).Ports) | Select-Object -Unique)
            }
        }

        # Filter output if the Name parameter was specified
        if ($PSBoundParameters.ContainsKey("Name")) {
            $Endpoints | Where-Object { $_.Application -in $Name }
        }
        else {
            $Endpoints
        }
    }
}
