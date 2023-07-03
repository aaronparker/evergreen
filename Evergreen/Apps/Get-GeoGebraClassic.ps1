Function Get-GeoGebraClassic {
    <#
        .SYNOPSIS
            Get the current version and download URL for GeoGebra Classic.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split('-'))[1])
    )
    foreach ($item in $res.Get.Download.Uri.GetEnumerator()) {
        # Get the latest GeoGebra Classic version
        $Content = Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri[$item.Key]

        # Construct the output; Return the custom object to the pipeline
        If ($Null -ne $Content) {
            $version = [RegEx]::Match($Content.ResponseUri, $res.Get.Download.MatchVersion).Value.TrimStart('-').Replace('-', '.')

            $PSObject = [PSCustomObject] @{
                Version = $version
                Type    = 'Msi'
                URI     = $Content.ResponseUri
            }
            Write-Output -InputObject $PSObject

            $PSObject = [PSCustomObject] @{
                Version = $version
                Type    = 'Exe'
                URI     = $Content.ResponseUri -replace '.msi$', '.exe'
            }
            Write-Output -InputObject $PSObject
        }
    }

}
