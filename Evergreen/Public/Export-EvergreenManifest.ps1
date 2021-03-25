Function Export-EvergreenManifest {
    <#
        .SYNOPSIS
            Exports an Evergreen application JSON manifest as a hashtable.

        .DESCRIPTION
            Exports an Evergreen application JSON manifest as a hashtable.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .PARAMETER Name
            The application name to return details for. The list of supported applications can be found with Find-EvergreenApp.

        .EXAMPLE
            Export-EvergreenManifest -Name "MicrosoftEdge"

            Description:
            Exports the application manifest for the application "MicrosoftEdge".
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Name = "Template"
    )
    
    $Output = Get-FunctionResource -AppName $Name
    If ($Output) { Write-Output -InputObject $Output }
}
