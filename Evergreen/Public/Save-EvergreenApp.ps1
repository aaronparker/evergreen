Function Save-EvergreenApp {
    <#
        .SYNOPSIS
            Saves target URLs passed to this function from Evergreen output to simplify downloads.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-AdobeAcrobat | Save-EvergreenApp -Path "C:\Temp\Adobe"

            Description:
            Downloads all of the URIs returned by Get-AdobeAcrobat to C:\Temp\Adobe\<version>.

        .EXAMPLE
            Get-AdobeAcrobat | Save-EvergreenApp -Path "C:\Temp\Adobe"

            Description:
            Downloads all of the URIs returned by Get-AdobeAcrobat to C:\Temp\Adobe\<version>.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/Evergreen/")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $False, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $False, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

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
        
        # Enable TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Warning -Message "$($MyInvocation.MyCommand): This function is currently in preview. Use at your own risk."
    }

    Process {

        # Loop through each object and download to the target path
        ForEach ($Object in $InputObject) {

            #region Validate the URI property and find the output filename
            If ([System.Boolean]($Object.URI)) {
                Write-Verbose -Message "$($MyInvocation.MyCommand):            URL: $($Object.URI)."
                If ([System.Boolean]($Object.FileName)) {
                    $OutFile = $Object.FileName
                }
                ElseIf ([System.Boolean]($Object.URI)) {
                    $OutFile = Split-Path -Path $Object.URI -Leaf
                }
            }
            Else {
                Write-Error -Message "$($MyInvocation.MyCommand): Object does not have valid URI property."
                Break
            }
            #endregion

            # Resolve $Path to build the initial value of $OutPath
            $OutPath = Resolve-Path -Path $Path -ErrorAction "SilentlyContinue"
            If ($Null -ne $OutPath) {

                #region Validate the Version property
                If ([System.Boolean]($Object.Version)) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand):        Version: $($Object.Version)."
                    $OutPath = Join-Path -Path $OutPath -ChildPath $Object.Version
                    If (Test-Path -Path $OutPath) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand):   Path exists: $OutPath."
                    }
                    Else {
                        try {
                            $params = @{
                                Path        = $OutPath
                                ItemType    = "Directory"
                                ErrorAction = "SilentlyContinue"
                            }
                            New-Item @params > $Null
                        }
                        catch {
                            Write-Error -Message "$($MyInvocation.MyCommand): Failed to create target directory. Error failed with: $($_.Exception.Message)."
                            Break
                        }
                    }
                }
                Else {
                    Write-Error -Message "$($MyInvocation.MyCommand): Object does not have valid Version property."
                    Break
                }
                #endregion

                #region Validate the Language property
                If ([System.Boolean]($Object.Language)) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand):       Language: $($Object.Language)."
                    $OutPath = Join-Path -Path $OutPath -ChildPath $Object.Language
                    If (Test-Path -Path $OutPath) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand):   Path exists: $OutPath."
                    }
                    Else {
                        try {
                            $params = @{
                                Path        = $OutPath
                                ItemType    = "Directory"
                                ErrorAction = "SilentlyContinue"
                            }
                            New-Item @params > $Null
                        }
                        catch {
                            Write-Error -Message "$($MyInvocation.MyCommand): Failed to create target directory. Error failed with: $($_.Exception.Message)."
                            Break
                        }
                    }
                }
                #endregion

                #region Validate the Architecture property
                If ([System.Boolean]($Object.Architecture)) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand):   Architecture: $($Object.Architecture)."
                    $OutPath = Join-Path -Path $OutPath -ChildPath $Object.Architecture
                    If (Test-Path -Path $OutPath) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand):   Path exists: $OutPath."
                    }
                    Else {
                        try {
                            $params = @{
                                Path        = $OutPath
                                ItemType    = "Directory"
                                ErrorAction = "SilentlyContinue"
                            }
                            New-Item @params > $Null
                        }
                        catch {
                            Write-Error -Message "$($MyInvocation.MyCommand): Failed to create target directory. Error failed with: $($_.Exception.Message)."
                            Break
                        }
                    }
                }
                #endregion
                Write-Verbose -Message "$($MyInvocation.MyCommand): Downloading to: $(Join-Path -Path $OutPath -ChildPath $OutFile)."
            }
            Else {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failed validating $Path."
                Break
            }

            #region Download the file
            If ($PSCmdlet.ShouldProcess($Object.URI, "Download")) {
                try {
                    
                    # Download the file
                    $params = @{
                        Uri             = $Object.URI
                        OutFile         = $(Join-Path -Path $OutPath -ChildPath $OutFile)
                        UseBasicParsing = $True
                        PassThru        = $True
                        ErrorAction     = "SilentlyContinue"
                    }
                    If ($PSBoundParameters.ContainsKey("Proxy")) {
                        $params.Proxy = $Proxy
                    }
                    If ($PSBoundParameters.ContainsKey("ProxyCredential")) {
                        $params.ProxyCredential = $ProxyCredential
                    }
                    Invoke-WebRequest @params
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): URL: [$($Object.URI)]."
                    Write-Warning -Message "$($MyInvocation.MyCommand): Download failed with: [$($_.Exception.Message)]"
                }

                #region Write the downloaded file path to the pipeline
                If (Test-Path -Path $(Join-Path -Path $OutPath -ChildPath $OutFile)) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Successfully downloaded: $(Join-Path -Path $OutPath -ChildPath $OutFile)."
                    $Output = [PSCustomObject] @{
                        Path = $(Join-Path -Path $OutPath -ChildPath $OutFile)
                    }
                    Write-Output -InputObject $Output
                }
                #endregion
            }
            #endregion
        }
    }

    End {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Complete."
    }
}