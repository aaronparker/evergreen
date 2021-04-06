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
    param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the ControlUp Agent JSON
    $Object = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri     
    If ($Null -ne $Object) {
       
        # Strip out the Google script return in the request and convert to JSON
        <#try {
            $Json = [RegEx]::Match($Content, $res.Get.Update.Matches).Value | ConvertFrom-Json
        }
        catch {
            Throw $_
            Break
        }#>
    
        # Build and array of the latest release and download URLs
        ForEach ($item in $Object) {
            $PSObject = [PSCustomObject] @{
                Version      = $Object.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                URI          = $Object.($res.Get.Update.Properties.Console)
            }
            Write-Output -InputObject $PSObject
        }
    }
}
