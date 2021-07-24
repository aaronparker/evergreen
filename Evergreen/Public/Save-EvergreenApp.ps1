Function Save-EvergreenApp {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/evergreen/save/")]
    [Alias("sea")]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Path = (Resolve-Path -Path $PWD),

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
        
        # Test $Path and attempt to create it if it doesn't exist
        If (Test-Path -Path $Path -PathType "Container") {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Path exists: $Path."
        } 
        Else {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Path does not exist: $Path."
            try {
                $params = @{
                    Path        = $Path
                    PathType    = "Container"
                    ErrorAction = "SilentlyContinue"
                }
                New-Item @params
            }
            catch {
                Throw "Failed to create $Path with: $($_)"
            }
        }

        # Enable TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Warning -Message "$($MyInvocation.MyCommand): This function is currently in preview. Output paths cannot be customised."
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

            # Resolve $Path to build the initial value of $OutPath
            $OutPath = Resolve-Path -Path $Path -ErrorAction "SilentlyContinue"
            If ($Null -ne $OutPath) {

                #region Validate the Version property
                If ([System.Boolean]($Object.Version)) {

                    # Build $OutPath with the "Channel", "Release", "Language", "Architecture" properties
                    $OutPath = New-EvergreenPath -InputObject $Object -Path $OutPath
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Downloading to: $(Join-Path -Path $OutPath -ChildPath $OutFile)."
                }
                Else {
                    Throw "$($MyInvocation.MyCommand): Object does not have valid Version property."
                }
                #endregion
            }
            Else {
                Throw "$($MyInvocation.MyCommand): Failed validating $Path."
            }

            # Download the file
            If ($PSCmdlet.ShouldProcess($Object.URI, "Download")) {
                If ($PSBoundParameters.ContainsKey("Force") -or !(Test-Path -Path $(Join-Path -Path $OutPath -ChildPath $OutFile))) {

                    try {                    
                        #region Download the file
                        $params = @{
                            Uri             = $Object.URI
                            OutFile         = $(Join-Path -Path $OutPath -ChildPath $OutFile)
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
                    }
                    catch [System.Exception] {
                        Throw "$($MyInvocation.MyCommand): URL: [$($Object.URI)]. Download failed with: [$($_.Exception.Message)]"
                    }
                }

                #region Write the downloaded file path to the pipeline
                If (Test-Path -Path $(Join-Path -Path $OutPath -ChildPath $OutFile)) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Successfully downloaded: $(Join-Path -Path $OutPath -ChildPath $OutFile)."
                    Write-Output -InputObject (Get-ChildItem -Path (Join-Path -Path $OutPath -ChildPath $OutFile))
                }
                #endregion
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
