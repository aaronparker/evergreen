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
        Write-Information -MessageData "`nPlease list supported application names with Find-EvergreenApp." -InformationAction "Continue"
        Write-Information -MessageData "Find out how to contribute a new application to the Evergreen project at: $($script:resourceStrings.Uri.Docs)." -InformationAction "Continue"
        try {
            $List = Find-EvergreenApp -Name $Name -ErrorAction "SilentlyContinue" -WarningAction "SilentlyContinue"
        }
        catch {
            $List = @{
                Name = "No applications match '$Name'"
            }
        }
        Write-Information -MessageData "`n'$Name' not found. Evergreen supports these similar applications:" -InformationAction "Continue"
        $List | Select-Object -ExpandProperty "Name" | Write-Information -InformationAction "Continue"
        Write-Information -MessageData "" -InformationAction "Continue"
        throw "Failed to retrieve manifest for application: $Name."
    }
    if ($Output) {
        Write-Output -InputObject $Output
    }
}
