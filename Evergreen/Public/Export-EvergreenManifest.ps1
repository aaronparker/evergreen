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
            https://stealthpuppy.com/Evergreen/

        .PARAMETER Name
            The application name to return details for. The list of supported applications can be found with Find-EvergreenApp.

        .EXAMPLE
            Export-EvergreenManifest -Name "MicrosoftEdge"

            Description:
            Exports the application manifest for the application "MicrosoftEdge".
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/Evergreen/")]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Name
    )
    
    try {
        $Output = Get-FunctionResource -AppName $Name
    }
    catch {
        Throw "Failed to retrieve manifest for application: $Name."
    }
    If ($Output) {
        Write-Output -InputObject $Output
    }
    Else {
        Write-Warning -Message "Please list valid application names with Find-EvergreenApp."
        Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Documentation)."
        Throw "Cannot find application: $Name."
    }
}
