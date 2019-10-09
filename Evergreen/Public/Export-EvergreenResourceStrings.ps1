Function Export-EvergreenResourceStrings {
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()
    
    Write-Output -InputObject $script:resourceStrings
}