Function Invoke-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/evergreen/invoke/")]
    [Alias("iea")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify an application name. Use Find-EvergreenApp to list supported applications.")]
        [ValidateNotNull()]
        [System.String] $Name
    )

    process {
        try {
            Find-EvergreenApp -Name $Name | Out-Null
            $params = @{
                Uri         = "https://evergreen-api.stealthpuppy.com/app/$Name"
                ErrorAction = "Stop"
            }
            Invoke-RestMethodWrapper @params
        }
        catch {
            throw $_
        }
    }
}
