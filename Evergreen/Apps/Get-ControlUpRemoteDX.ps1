function Get-ControlUpRemoteDX {
    <#

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
    if ($null -ne $Object) {

        # Build and array of the latest release and download URLs
        foreach ($item in ($Object.($res.Get.Update.Properties.RemoteDX) | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
            if ($Object.($res.Get.Update.Properties.RemoteDX).$item -match "windows") {
                $PSObject = [PSCustomObject] @{
                    Version      = $Object.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                    Plugin       = $item
                    Architecture = Get-Architecture -String $item
                    URI          = $Object.($res.Get.Update.Properties.RemoteDX).$item.Trim()
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
