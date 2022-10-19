Function Get-EgnyteDesktopApp {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Egnyte Desktop App.

        .NOTES
            Site: https://stealthpuppy.com
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


    # Get update from the application update URI
    $Update = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    If ($Null -ne $Update) {

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Update.enclosure.version
            SHA1    = $Update.enclosure.sha1Checksum
            URI     = $Update.enclosure.url
        }
        Write-Output -InputObject $PSObject
    }
}
