Function Export-EvergreenManifest {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/evergreen/")]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNull()]
        [System.String] $Name
    )
    
    try {
        $Output = Get-FunctionResource -AppName $Name
    }
    catch {
        Write-Warning -Message "Please list valid application names with Find-EvergreenApp."
        Write-Warning -Message "Documentation on how to contribute a new application to the Evergreen project can be found at: $($script:resourceStrings.Uri.Docs)."
        Throw "Failed to retrieve manifest for application: $Name."
    }
    If ($Output) {
        Write-Output -InputObject $Output
    }
}
