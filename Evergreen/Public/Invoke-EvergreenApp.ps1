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
        Write-Warning -Message "$($MyInvocation.MyCommand) is experimental and functionality may change."
        $params = @{
            Uri = "https://stealthpuppy.com/apptracker/json/$Name.json"
        }
        Invoke-RestMethodWrapper @params
    }

    end {
    }
}
