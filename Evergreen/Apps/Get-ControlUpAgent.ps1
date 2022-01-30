Function Get-ControlUpAgent {
    <#
        .SYNOPSIS
            Gets the ControlUp latest agent version and download URI for 64-bit or 32-bit Windows, .NET Framework 3.5 or .NET Framework 4.5.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
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
    $Object = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    If ($Null -ne $Object) {

        # Build and array of the latest release and download URLs
        ForEach ($item in ($Object.($res.Get.Update.Properties.Agent) | Get-Member -MemberType "NoteProperty" | Select-Object -ExpandProperty "Name")) {
            $PSObject = [PSCustomObject] @{
                Version      = $Object.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                Framework    = $item
                Architecture = Get-Architecture -String $item
                URI          = $Object.($res.Get.Update.Properties.Agent).$item
            }
            Write-Output -InputObject $PSObject
        }
    }
}
