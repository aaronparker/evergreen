function Get-McNeelRhino {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of Rhino.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Release in $res.Get.Update.Uri.GetEnumerator()) {
        foreach ($Language in $res.Get.Update.Languages) {

            # Query the Rhino update API
            $params = @{
                Uri                   = $Release.Value -replace "#language", $Language
                AllowInsecureRedirect = $true
            }
            $UpdateFeed = Invoke-EvergreenRestMethod @params
            if ($null -ne $UpdateFeed) {

                # Construct the output; Return the custom object to the pipeline
                $PSObject = [PSCustomObject] @{
                    Version  = $UpdateFeed.ProductVersionDescription.Version
                    Release  = $Release.Name
                    Language = $Language
                    URI      = $UpdateFeed.ProductVersionDescription.DownloadUrl
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
