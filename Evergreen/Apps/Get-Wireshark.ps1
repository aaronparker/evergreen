function Get-Wireshark {
    <#
        .SYNOPSIS
            Returns the available Wireshark versions and download URIs.

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

    # Resolve the URL to the target location
    foreach ($item in $res.Get.Update.Uri.GetEnumerator()) {
        $params = @{
            Uri       = $res.Get.Update.Uri[$item.Key]
            UserAgent = $res.Get.Update.UserAgent
        }
        $UpdateFeed = Invoke-EvergreenRestMethod @params

        if ($null -ne $UpdateFeed) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($Update.enclosure.count) releases."
            foreach ($Update in $UpdateFeed) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version $($enclosure.version) for this release."

                # Build the output object; Output object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = $Update.enclosure.version
                    Release      = $(if ($Update.minimumSystemVersion -match "6.1.0") { "OldStable" } else { "Stable" } )
                    Architecture = $item.Name
                    Type         = $([System.IO.Path]::GetExtension($Update.enclosure.url).Split(".")[-1])
                    URI          = $Update.enclosure.url
                }
                Write-Output -InputObject $PSObject

                # Build the output object; Output object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version      = $Update.enclosure.version
                    Release      = $(if ($Update.minimumSystemVersion -match "6.1.0") { "OldStable" } else { "Stable" } )
                    Architecture = $item.Name
                    Type         = "msi"
                    URI          = $($Update.enclosure.url -replace ([System.IO.Path]::GetExtension($Update.enclosure.url).Split(".")[-1]), "msi")
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
