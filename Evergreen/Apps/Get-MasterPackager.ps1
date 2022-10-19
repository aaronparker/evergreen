Function Get-MasterPackager {
    <#
        .SYNOPSIS
            Returns the available Master Packager versions and download URIs.

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

    # Read the update URI
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Version = Invoke-RestMethodWrapper @params

    # Read the JSON and build an array of platform, channel, version
    If ($Null -ne $Version) {

        # Step through each installer type
        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {

            # Build the output object; Output object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Version
                Type    = $item.Name
                URI     = $res.Get.Download.Uri[$item.Key] -replace $res.Get.Download.ReplaceText.Version, $Version
            }
            Write-Output -InputObject $PSObject
        }
    }
}
