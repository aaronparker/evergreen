Function Get-ProgressChefInfraClient {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

            https://docs.chef.io/api_omnitruck/
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Project in $res.Get.Update.Projects) {
        foreach ($Channel in $res.Get.Update.Channels) {
            foreach ($Architecture in $res.Get.Update.Architectures) {
                foreach ($Platform in $res.Get.Update.PlatformVersions) {

                    # Build the URL to query for the installer
                    $metadata_array = ("?v=latest",
                        "p=windows",
                        "pv=$Platform",
                        "m=$Architecture")
                    $UpdateUrl = $res.Get.Update.Uri + [System.String]::Join('&', $metadata_array)

                    # Get details for this installer
                    $params = @{
                        Uri = $UpdateUrl -replace "#channel", $Channel -replace "#project", $Project
                    }
                    $UpdateObject = Invoke-RestMethodWrapper @params

                    if ($null -ne $UpdateObject) {
                        $CsvObject = $UpdateObject | ConvertFrom-Csv -Delimiter "`t" -Header "Property", "Value"

                        # Construct the output; Return the custom object to the pipeline
                        $PSObject = [PSCustomObject] @{
                            Version      = $CsvObject | Where-Object { $_.Property -eq "version" } | Select-Object -ExpandProperty "Value"
                            Architecture = Get-Architecture -String $Architecture
                            Channel      = $Channel
                            Platform     = $Platform
                            Sha256       = $CsvObject | Where-Object { $_.Property -eq "sha256" } | Select-Object -ExpandProperty "Value"
                            URI          = $CsvObject | Where-Object { $_.Property -eq "url" } | Select-Object -ExpandProperty "Value"
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
