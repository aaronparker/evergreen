Function Get-ControlUpAgent {
    <#
        .SYNOPSIS
            Gets the ControlUp latest agent version and download URI for 64-bit or 32-bit Windows, .NET Framework 3.5 or .NET Framework 4.5.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ControlUpAgent

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
        ForEach ($item in ($Json.($res.Get.Update.Properties.Agent) | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)) {
            $PSObject = [PSCustomObject] @{
                Version      = $Json.($res.Get.Update.Properties.Version) -replace $res.Get.Update.ReplaceText, ""
                Framework    = $item
                Architecture = Get-Architecture -String $item
                URI          = $Json.($res.Get.Update.Properties.Agent).$item
            }
            Write-Output -InputObject $PSObject
        }
    }
}
