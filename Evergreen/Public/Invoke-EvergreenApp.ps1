function Invoke-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    [Alias("iea", "Get-EvergreenAppFromApi")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify an application name. Use Find-EvergreenApp to list supported applications.")]
        [ValidateNotNull()]
        [Alias("ApplicationName")]
        [System.String] $Name
    )

    process {
        try {
            $params = @{
                Uri         = "https://evergreen-api.stealthpuppy.com/app/$Name"
                ErrorAction = "Stop"
            }
            Invoke-EvergreenRestMethod @params
        }
        catch {
            throw $_
        }
    }
}
