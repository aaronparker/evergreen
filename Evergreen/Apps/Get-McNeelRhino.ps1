Function Get-McNeelRhino {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of Rhino.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($Release in $res.Get.Update.GetEnumerator()) {

        # Query the Rhino update API
        # This requires redirection so Invoke-RestMethodWrapper produces "Operation is not valid due to the current state of the object."
        $Uri = Resolve-InvokeWebRequest -Uri $Release.Value
        $UpdateFeed = Invoke-RestMethod -Uri $Uri

        If ($Null -ne $UpdateFeed) {

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $updateFeed.ProductVersionDescription.Version
                Release = $Release.Name
                URI     = $updateFeed.ProductVersionDescription.DownloadUrl
            }
            Write-Output -InputObject $PSObject
        }
    }
}
