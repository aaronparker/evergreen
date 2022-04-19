Function Test-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/evergreen/test/", DefaultParameterSetName = "Path")]
    [Alias("tea")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass an application object from Get-EvergreenApp.")]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $False, Position = 1)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 2)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $NoProgress
    )

    begin {

        # Disable the Invoke-WebRequest progress bar for faster downloads
        if ($PSBoundParameters.ContainsKey("Verbose") -and !($PSBoundParameters.ContainsKey("NoProgress"))) {
            $ProgressPreference = [System.Management.Automation.ActionPreference]::Continue
        }
        else {
            $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }

        # Enable TLS 1.2
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    }

    process {

        # Loop through each object and download to the target path
        foreach ($Object in $InputObject) {

            #region Validate the URI property and find the output filename
            if ([System.Boolean]($Object.URI)) {
            }
            else {
                throw "$($MyInvocation.MyCommand): Object does not have valid URI property."
            }
            #endregion

            try {
                $params = @{
                    Uri             = $Object.URI
                    Method          = "HEAD"
                    UseBasicParsing = $True
                    ErrorAction     = "SilentlyContinue"
                }
                if ($PSBoundParameters.ContainsKey("Proxy")) {
                    $params.Proxy = $Proxy
                }
                if ($PSBoundParameters.ContainsKey("ProxyCredential")) {
                    $params.ProxyCredential = $ProxyCredential
                }
                $r = Invoke-WebRequest @params
                $Result = $True
            }
            catch [System.Exception] {
                $Result = $False
            }
            $PSObject = [PSCustomObject] @{
                URI    = $Object.URI
                Result = $Result
            }
            Write-Output -InputObject $PSObject
        }
    }

    end {
        if ($PSCmdlet.ShouldProcess("Remove variables")) {
            if (Test-Path -Path Variable:params) { Remove-Variable -Name "params" -ErrorAction "SilentlyContinue" }
            Remove-Variable -Name "OutPath", "OutFile" -ErrorAction "SilentlyContinue"
        }
    }
}
