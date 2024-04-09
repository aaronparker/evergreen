function Get-MicrosoftTeams {
    <#
        .SYNOPSIS
            Returns the available Microsoft Teams 2 versions and download URIs.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query for the download/update feed
    $Feed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    if ($null -ne $Feed) {

        foreach ($Release in $res.Get.Update.Releases.GetEnumerator()) {

            # Query the feed for each release type and expand the architectures in that release
            foreach ($Item in ($Feed.BuildSettings.$($Release.Value) | `
                        Get-Member -MemberType "NoteProperty" | `
                        Select-Object -ExpandProperty "Name" | `
                        Where-Object { $_ -in $res.Get.Download.Architecture })) {

                # Output the version object
                $PSObject = [PSCustomObject] @{
                    Version      = $Feed.BuildSettings.$($Release.Value).$Item.latestVersion
                    Release      = $Release.Name
                    Architecture = $Item
                    Type         = Get-FileType -File $Feed.BuildSettings.$($Release.Value).$Item.buildLink
                    URI          = $Feed.BuildSettings.$($Release.Value).$Item.buildLink
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
