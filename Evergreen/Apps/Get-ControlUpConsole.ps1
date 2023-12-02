Function Get-ControlUpConsole {
    <#
        .SYNOPSIS
            Gets the ControlUp console version and download URI

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

    # Query the ControlUp Agent JSON
    $Object = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    If ($Null -ne $Object) {

        # Build and array of the latest release and download URLs
        ForEach ($item in $Object) {
            $PSObject = [PSCustomObject] @{
                Version      = $Object.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                URI          = $Object.($res.Get.Update.Properties.Console).Trim()
            }
            Write-Output -InputObject $PSObject
        }
    }
}
