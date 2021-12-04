Function Save-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/evergreen/save/", DefaultParameterSetName = "Path")]
    [Alias("sea")]
    param (
        [Parameter(
            Mandatory = $True,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass an application object from Get-EvergreenApp.")]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(
            Mandatory = $False,
            Position = 1,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify a top-level directory path where the application installers will be saved into.",
            ParameterSetName = "Path")]
        #[ValidateNotNull()]
        [System.IO.FileInfo] $Path,

        [Parameter(
            Mandatory = $False,
            Position = 1,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify a single directory path where all application installers will be saved into.",
            ParameterSetName = "CustomPath")]
        #[ValidateNotNull()]
        [System.IO.FileInfo] $CustomPath,

        [Parameter(Mandatory = $False, Position = 2)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 3)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $NoProgress
    )

    Begin { 

        # Disable the Invoke-WebRequest progress bar for faster downloads
        If ($PSBoundParameters.ContainsKey("Verbose") -and !($PSBoundParameters.ContainsKey("NoProgress"))) {
            $ProgressPreference = [System.Management.Automation.ActionPreference]::Continue
        }
        Else {
            $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
        }

        # Path variable from parameters set via -Path or -CustomPath
        Switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                If ([System.String]::IsNullOrEmpty($Path)) { Throw "Cannot bind argument to parameter 'Path' because it is null."}
                $NewPath = $Path
            }
            "CustomPath" {
                If ([System.String]::IsNullOrEmpty($CustomPath)) { Throw "Cannot bind argument to parameter 'CustomPath' because it is null."}
                $NewPath = $CustomPath
            }
        }
        
        #region Test $Path and attempt to create it if it doesn't exist
        If (Test-Path -Path $NewPath -PathType "Container") {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Path exists: $NewPath."
        } 
        Else {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Path does not exist: $NewPath."
            try {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Create: $NewPath."
                $params = @{
                    Path        = $NewPath
                    ItemType    = "Container"
                    ErrorAction = "SilentlyContinue"
                }
                New-Item @params | Out-Null
            }
            catch {
                Throw "$($MyInvocation.MyCommand): Failed to create $NewPath with: $($_.Exception.Message)"
            }
        }
        #endregion

        # Enable TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    Process {

        # Loop through each object and download to the target path
        ForEach ($Object in $InputObject) {

            #region Validate the URI property and find the output filename
            If ([System.Boolean]($Object.URI)) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): URL: $($Object.URI)."
                If ([System.Boolean]($Object.FileName)) {
                    $OutFile = $Object.FileName
                }
                ElseIf ([System.Boolean]($Object.URI)) {
                    $OutFile = Split-Path -Path $Object.URI -Leaf
                }
            }
            Else {
                Throw "$($MyInvocation.MyCommand): Object does not have valid URI property."
            }
            #endregion

            # Handle the output path depending on whether -Path or -CustomPath are used
            Switch ($PSCmdlet.ParameterSetName) {
                "Path" {
                    # Resolve $Path to build the initial value of $OutPath
                    $OutPath = Resolve-Path -Path $Path -ErrorAction "SilentlyContinue"
                    If ($Null -ne $OutPath) {

                        #region Validate the Version property
                        If ([System.Boolean]($Object.Version)) {

                            # Build $OutPath with the "Channel", "Release", "Language", "Architecture" properties
                            $OutPath = New-EvergreenPath -InputObject $Object -Path $OutPath
                        }
                        Else {
                            Throw "$($MyInvocation.MyCommand): Object does not have valid Version property."
                        }
                        #endregion
                    }
                    Else {
                        Throw "$($MyInvocation.MyCommand): Failed validating $OutPath."
                    }
                }
                "CustomPath" {
                    $OutPath = Resolve-Path -Path $CustomPath -ErrorAction "Stop"
                }
            }

            # Download the file
            If ($PSCmdlet.ShouldProcess($Object.URI, "Download")) {

                $DownloadFile = $(Join-Path -Path $OutPath -ChildPath $OutFile)
                If ($PSBoundParameters.ContainsKey("Force") -or !(Test-Path -Path $DownloadFile -PathType "Leaf" -ErrorAction "SilentlyContinue")) {

                    try {                    
                        #region Download the file
                        $params = @{
                            Uri             = $Object.URI
                            OutFile         = $DownloadFile
                            UseBasicParsing = $True
                            ErrorAction     = "Continue"
                        }
                        If ($PSBoundParameters.ContainsKey("Proxy")) {
                            $params.Proxy = $Proxy
                        }
                        If ($PSBoundParameters.ContainsKey("ProxyCredential")) {
                            $params.ProxyCredential = $ProxyCredential
                        }
                        Invoke-WebRequest @params
                        #endregion

                        #region Write the downloaded file path to the pipeline
                        If (Test-Path -Path $DownloadFile) {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Successfully downloaded: $DownloadFile."
                            Write-Output -InputObject $(Get-ChildItem -Path $DownloadFile)
                        }
                        #endregion
                    }
                    catch [System.Exception] {
                        Throw "$($MyInvocation.MyCommand): URL: [$($Object.URI)]. Download failed with: [$($_.Exception.Message)]"
                    }
                }
                Else {
                    #region Write the downloaded file path to the pipeline
                    If (Test-Path -Path $DownloadFile) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): File exists: $DownloadFile."
                        Write-Output -InputObject $(Get-ChildItem -Path $DownloadFile)
                    }
                    #endregion
                }
            }
        }
    }

    End {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Complete."
        If ($PSCmdlet.ShouldProcess("Remove variables")) {
            If (Test-Path -Path Variable:params) { Remove-Variable -Name "params" -ErrorAction "SilentlyContinue" }
            Remove-Variable -Name "OutPath", "OutFile" -ErrorAction "SilentlyContinue" 
        }
    }
}
