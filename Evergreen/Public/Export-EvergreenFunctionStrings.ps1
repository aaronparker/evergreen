Function Export-EvergreenFunctionStrings {
    <#
        .SYNOPSIS
            Returns a hashtable of a function manifest
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.String] $AppName = "Template"
    )
    
    Write-Output -InputObject (Get-FunctionResource -AppName $AppName)
}
