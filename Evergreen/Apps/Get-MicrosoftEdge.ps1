Function Get-MicrosoftEdge {
    <#
        .SYNOPSIS
            Returns the available Microsoft Edge versions and channels by querying the official Microsoft version JSON.

        .NOTES
            Author: Aaron Parker
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the JSON and convert to a PowerShell object. Return the current release version of Edge
    $Feed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Read the JSON and build an array of platform, channel, architecture, version
    if ($null -ne $Feed) {
        foreach ($Item in $Feed) {
            foreach ($Release in $Item.Releases) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Item.Releases.Count) release(s)."
                if ($Release.Platform -in $res.Get.Update.Platforms) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Release.Platform) release for $($Item.Product)."
                    foreach ($Artifact in $Release.Artifacts) {
                        [PSCustomObject]@{
                            Version                 = $Release.ProductVersion
                            Date                    = $Release.PublishedTime
                            Channel                 = $Item.Product
                            Release                 = "Enterprise"
                            Expiry                  = $Release.ExpectedExpiryDate
                            $Artifact.HashAlgorithm = $Artifact.Hash
                            Size                    = $([Math]::Round($Artifact.SizeInBytes / 1MB, 2))
                            Architecture            = $Release.Architecture
                            Type                    = $Artifact.ArtifactName
                            URI                     = $Artifact.Location
                        }
                    }
                }
            }
        }
    }
}
