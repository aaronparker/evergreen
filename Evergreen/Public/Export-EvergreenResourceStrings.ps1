Function Export-EvergreenResourceStrings {
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()
    
    Write-Output -InputObject $script:resourceStrings
}