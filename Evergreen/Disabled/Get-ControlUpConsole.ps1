Function Get-ControlUpConsole {
    <#
        .SYNOPSIS
            Gets the ControlUp console version and download URI

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ControlUpConsole

            Description:
            Returns the latest ControlUp Agent with .NET Framework 4.5 support for 64-bit Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the ControlUp Agent JSON
    $Content = Invoke-WebRequestWrapper -Uri $res.Get.Update.Uri    
    If ($Null -ne $Content) {
       
        # Strip out the Google script return in the request and convert to JSON
        try {
            $Json = [RegEx]::Match($Content, $res.Get.Update.Matches).Value | ConvertFrom-Json
        }
        catch {
            Throw $_
            Break
        }
    
        # Build and array of the latest release and download URLs
        ForEach ($item in $Json) {
            $PSObject = [PSCustomObject] @{
                Version      = $Json.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                URI          = $Json.($res.Get.Update.Properties.Console)
            }
            Write-Output -InputObject $PSObject
        }
    }
}
