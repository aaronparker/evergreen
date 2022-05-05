Function Get-MicrosoftEdgeDriver {
    <#
        .SYNOPSIS
            Returns the available Microsoft Edge Driver versions and downloads.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
    $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri

    # Read the JSON and build an array of platform, channel, architecture, version
    if ($Null -ne $updateFeed) {
        foreach ($platform in $res.Get.Update.Platforms) {

            # For each product (Stable, Beta etc.)
            foreach ($channel in $res.Get.Update.Channels) {
                foreach ($architecture in $res.Get.Update.Architectures) {

                    # Sort for the latest release
                    $latestRelease = $updateFeed | Where-Object { $_.Product -eq $channel } | `
                        Select-Object -ExpandProperty "Releases" | `
                        Where-Object { $_.Platform -eq $platform -and $_.Architecture -eq $architecture } | `
                        Sort-Object -Property @{ Expression = { [System.Version]$_.ProductVersion }; Descending = $true } | `
                        Select-Object -First 1
                    Write-Verbose -Message "Found $($latestRelease.Count) releases."

                    # Create the output object/s
                    foreach ($release in $latestRelease) {
                        if ($release.Artifacts.Count -gt 0) {

                            # Output object to the pipeline
                            $PSObject = [PSCustomObject] @{
                                Version      = $release.ProductVersion
                                Channel      = $channel
                                Architecture = $architecture
                                URI          = $($res.Get.Download.Uri[$architecture] -replace "#version", $release.ProductVersion)
                            }
                            Write-Output -InputObject $PSObject
                        }
                    }
                }
            }
        }
    }
    else {
        Write-Error -Message "$($MyInvocation.MyCommand): Failed to return content from: $($res.Get.Update.Uri)."
    }
}
