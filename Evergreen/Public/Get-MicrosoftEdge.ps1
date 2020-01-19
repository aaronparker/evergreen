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
    Param (
        [Parameter()]
        [ValidateSet('Enterprise', 'Consumer')]
        [System.String[]] $View = "Enterprise"
    )

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query for each view
    ForEach ($item in $View) {

        # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
        $Content = Invoke-WebContent -Uri "$($res.Get.Uri)$($res.Get.Views[$View])"

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $Content) {

            # Conver object from JSON
            $Json = $Content | ConvertFrom-Json

            # Build the output object
            ForEach ($item in $Json) {
                ForEach ($release in $item.Releases) {
                    If ($release.Artifacts.Location.Length -gt 0) {
                        $PSObject = [PSCustomObject] @{
                            Version      = $release.ProductVersion
                            Platform     = $release.Platform
                            Product      = $item.Product
                            Architecture = $release.Architecture
                            Date         = $release.PublishedTime
                            Hash         = $(If ($release.Artifacts.Hash.Count -gt 1) { $release.Artifacts.Hash[0] } Else { $release.Artifacts.Hash })
                            URI          = ($release.Artifacts.Location | Where-Object { $_ -match "msi$|exe$|pkg$|cab$" } )
                        }
                    }

                    # Output object to the pipeline
                    Write-Output -InputObject $PSObject
                }
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Uri)."
        }
    }
}
