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
        Write-Information -MessageData "" -InformationAction "Continue"
        Write-Information -MessageData "Please list supported application names with Find-EvergreenApp." -InformationAction "Continue"
        Write-Information -MessageData "Find out how to contribute a new application to the Evergreen project here: $($script:resourceStrings.Uri.Docs)." -InformationAction "Continue"
        $List = Find-EvergreenApp -Name $Name -ErrorAction "SilentlyContinue" -WarningAction "SilentlyContinue"
        Write-Information -MessageData "" -InformationAction "Continue"
        Write-Information -MessageData "'$Name' not found. Evergreen supports these similar applications:" -InformationAction "Continue"
        $List | Select-Object -ExpandProperty "Name" | Write-Information -InformationAction "Continue"
        Write-Information -MessageData "" -InformationAction "Continue"
        throw "Failed to retrieve manifest for application: $Name."
    }
    if ($Output) {
        Write-Output -InputObject $Output
    }
}
