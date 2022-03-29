Function Get-MicrosoftEdge {
    <#
        .SYNOPSIS
            Returns the available Microsoft Edge versions and channels by querying the official Microsoft version JSON.

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

    # Query for each view
    ForEach ($view in $res.Get.Update.Views.GetEnumerator()) {

        # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
        $updateFeed = Invoke-RestMethodWrapper -Uri "$($res.Get.Update.Uri)$($res.Get.Update.Views[$view.Key])"

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $updateFeed) {

            # For each product (Stable, Beta etc.)
            ForEach ($product in $res.Get.Update.Channels) {

                # Find the latest version
                Write-Verbose -Message "$($MyInvocation.MyCommand): Filter product: $product."
                $latestRelease = $updateFeed | Where-Object { $_.Product -eq $product } | `
                    Select-Object -ExpandProperty $res.Get.Update.ReleaseProperty | `
                    Where-Object { $_.Platform -in $res.Get.Update.Platform } | `
                    Sort-Object -Property $res.Get.Update.SortProperty -Descending | `
                    Select-Object -First 1
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $($latestRelease.ProductVersion)."

                # Expand the Releases property for that product version
                $releases = $updateFeed | Where-Object { $_.Product -eq $product } | `
                    Select-Object -ExpandProperty $res.Get.Update.ReleaseProperty | `
                    Where-Object { ($_.ProductVersion -eq $latestRelease.ProductVersion) -and ($_.Platform -in $res.Get.Update.Platform) -and ($_.Architecture -in $res.Get.Update.Architectures) }
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($releases.count) objects for: $product, with $($releases.Artifacts.count) artifacts."

                # Create the output objects
                ForEach ($release in $releases) {
                    If ($release.Artifacts.Count -gt 0) {
                        $PSObject = [PSCustomObject] @{
                            Version      = $release.ProductVersion
                            Platform     = $release.Platform
                            Channel      = $product
                            Release      = $view.Name
                            Architecture = $release.Architecture
                            Date         = ConvertTo-DateTime -DateTime $release.PublishedTime -Pattern $res.Get.Update.DatePattern
                            Hash         = $(If ($release.Artifacts.Hash.Count -gt 1) { $release.Artifacts.Hash[0] } Else { $release.Artifacts.Hash })
                            URI          = $(If ($release.Artifacts.Location.Count -gt 1) { $release.Artifacts.Location[0] } Else { $release.Artifacts.Location })
                        }

                        # Output object to the pipeline
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
