Function Get-MicrosoftEdge {
    <#
        .SYNOPSIS
            Returns the available Microsoft Edge versions.

        .DESCRIPTION
            Returns the available Microsoft Edge versions across all platforms and channels by querying the offical Microsoft version JSON.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .PARAMETER View
            Specify the target views - Enterprise or Consumer, for supported versions.

        .EXAMPLE
            Get-MicrosoftEdge

            Description:
            Returns the Microsoft Edge version for all Enterprise channels and platforms.

        .EXAMPLE
            Get-MicrosoftEdge -View Consumer

            Description:
            Returns the Microsoft Edge version for all Consumer channels and platforms.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query for each view
    ForEach ($view in $res.Get.Views.GetEnumerator()) {

        # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
        $Content = Invoke-WebContent -Uri "$($res.Get.Uri)$($res.Get.Views[$view.Key])"

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $Content) {

            # Convert object from JSON
            $EdgeReleases = $Content | ConvertFrom-Json

            # For each product (Stable, Beta etc.)
            ForEach ($product in $res.Get.Channels) {

                # Expand the Releases property for that product
                $releases = $EdgeReleases | Where-Object { $_.Product -eq $product } | `
                    Select-Object -ExpandProperty $res.Get.ReleaseProperty | `
                    Where-Object { $_.Platform -eq $res.Get.Platform } | `
                    Sort-Object -Property $res.Get.SortProperty | `
                    Select-Object -First 1

                ForEach ($release in $releases) {
                    If ($release.Artifacts.Location.Length -gt 0) {
                        $PSObject = [PSCustomObject] @{
                            Version      = $release.ProductVersion
                            Platform     = $release.Platform
                            Channel      = $product
                            Release      = $view.Name
                            Architecture = $release.Architecture
                            Date         = $release.PublishedTime
                            Hash         = $(If ($release.Artifacts.Hash.Count -gt 1) { $release.Artifacts.Hash[0] } Else { $release.Artifacts.Hash })
                            URI          = ($release.Artifacts.Location | Where-Object { $_ -match $res.Get.FileTypes } )
                        }

                        # Output object to the pipeline
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Uri)."
        }
    }
}
