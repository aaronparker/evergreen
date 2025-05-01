function Get-ControlUpMonitor {
    <#
        .SYNOPSIS
            Gets the ControlUp Monitor version and download URI

        .NOTES
            Author: Nathan Joseph
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the ControlUp VDI/DaaS Product JSON
    $Object = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    Write-Verbose $Object
    If ($Null -ne $Object) {
        # Build an array of the latest release and download URLs
        ForEach ($item in ($Object.($res.Get.Update.Properties.Monitor) | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
            $PSObject = [PSCustomObject] @{
                Version      = $Object.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                URI          = $Object.($res.Get.Update.Properties.Monitor).$item.Trim()
            }
            Write-Output -InputObject $PSObject
        }
    }
}
