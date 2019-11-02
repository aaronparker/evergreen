Function Export-EvergreenResourceStrings {
    <#
        .SYNOPSIS
            Returns a hashtable of the module manifest
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()
    
    Write-Output -InputObject $script:resourceStrings
}
