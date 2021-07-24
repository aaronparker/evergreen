Function Get-GitHubRepoRelease {
    <#
        .SYNOPSIS
            Calls the GitHub Releases API passed via $Uri, validates the response and returns a formatted object
            Example: https://api.github.com/repos/PowerShell/PowerShell/releases/latest

            TODO: support Basic or OAuth authentication to GitHub
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateScript( {
                If ($_ -match "^(https://api\.github\.com/repos/)([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)(/releases)") {
                    $True
                }
                Else {
                    Throw "'$_' must be in the format 'https://api.github.com/repos/user/repository/releases/latest'. Replace 'user' with the user or organisation and 'repository' with the target repository name."
                }
            })]
        [System.String] $Uri,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion = "(\d+(\.\d+){1,4}).*",

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VersionTag = "tag_name",

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Filter = "\.exe$|\.msi$|\.msp$|\.zip$",

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $ReturnVersionOnly
    )

    # Check that we aren't rate limited
    # https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting
    $params = @{
        Uri = "https://api.github.com/rate_limit"
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand): Checking for how many requests to the GitHub API we have left."
    $GitHubRate = Invoke-RestMethodWrapper @params
    
    If ($GitHubRate.rate.remaining -eq 0) {
        # We're rate limited, so output a special object
        Write-Warning -Message "$($MyInvocation.MyCommand): Requests to GitHub are being rate limited."
        $ResetWindow = [System.TimeZone]::CurrentTimeZone.ToLocalTime(([System.DateTime]'1/1/1970').AddSeconds($GitHubRate.rate.reset))
        Write-Warning -Message "$($MyInvocation.MyCommand): Rate limit window resets at: $($ResetWindow.ToShortDateString()) $($ResetWindow.ToShortTimeString())."
        $PSObject = [PSCustomObject] @{
            Version = "RateLimited"
            URI     = "https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting"
        }
        Write-Output -InputObject $PSObject
    }
    Else {

        # Retrieve the releases from the GitHub API 
        Write-Verbose -Message "$($MyInvocation.MyCommand): We have $($GitHubRate.rate.remaining) requests left to the GitHub API in this window."
        try {
        
            # Use TLS for connections
            $SslProtocol = "Tls12"
            Write-Verbose -Message "$($MyInvocation.MyCommand): Set TLS to $SslProtocol."
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::$SslProtocol

            # Invoke the GitHub releases REST API
            # Note that the API performs rate limiting.
            # https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#get-the-latest-release
            $params = @{
                ContentType        = "application/vnd.github.v3+json"
                ErrorAction        = "SilentlyContinue"
                MaximumRedirection = 0
                DisableKeepAlive   = $true
                UseBasicParsing    = $true
                UserAgent          = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
                Uri                = $Uri
            }
            Write-Verbose -Message "$($MyInvocation.MyCommand): Get GitHub release from: $Uri."
            $response = $True
            $release = Invoke-RestMethod @params
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): request to Invoke-RestMethodWrapper failed."
            $response = $False
        }

        If ($response -eq $True) {

            If ($Null -eq $script:resourceStrings.Properties.GitHub) {
                Write-Warning -Message "$($MyInvocation.MyCommand): Unable to validate release against GitHub releases property object."
                $validate = $True
            }
            Else {
                # Validate that $release has the expected properties
                Write-Verbose -Message "$($MyInvocation.MyCommand): Validating GitHub release object."
                ForEach ($item in $release) {

                    # Compare the GitHub release object with properties that we expect
                    $params = @{
                        ReferenceObject  = $script:resourceStrings.Properties.GitHub
                        DifferenceObject = (Get-Member -InputObject $item -MemberType NoteProperty)
                        PassThru         = $True
                        ErrorAction      = "Continue"
                    }
                    $missingProperties = Compare-Object @params

                    # Throw an error for missing properties
                    If ($Null -ne $missingProperties) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Validated successfully."
                        $validate = $True
                    }
                    Else {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Validation failed."
                        $validate = $False
                        $missingProperties | ForEach-Object {
                            Throw [System.Management.Automation.ValidationMetadataException] "$($MyInvocation.MyCommand): Property: '$_' missing"
                        }
                    }
                }
            }

            # Build and array of the latest release and download URLs
            If ($validate) {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($release.count) release/s."
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($release.assets.count) asset/s."

                If ($PSBoundParameters.ContainsKey("ReturnVersionOnly")) {
                    # Return just the version string
                    try {
                        $version = [RegEx]::Match($release[0].$VersionTag, $MatchVersion).Captures.Groups[1].Value
                    }
                    catch {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number, returning: $($release[0].$VersionTag)."
                        $version = $item.$VersionTag
                    }
                    # Build the output object
                    $PSObject = [PSCustomObject] @{
                        Version = $version
                    }
                    Write-Output -InputObject $PSObject
                }
                Else {
                    ForEach ($item in $release) {
                        ForEach ($asset in $item.assets) {

                            # Filter downloads by matching the RegEx in the manifest. The the RegEx may perform includes and excludes
                            If ($asset.browser_download_url -match $Filter) {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Building Windows release output object with: $($asset.browser_download_url)."

                                # Capture the version string from the specified release tag
                                try {
                                    $version = [RegEx]::Match($item.$VersionTag, $MatchVersion).Captures.Groups[1].Value
                                }
                                catch {
                                    Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number, returning: $($item.$VersionTag)."
                                    $version = $item.$VersionTag
                                }

                                # Build the output object
                                $PSObject = [PSCustomObject] @{
                                    Version      = $version
                                    Platform     = Get-Platform -String $asset.browser_download_url
                                    Architecture = Get-Architecture -String $asset.browser_download_url
                                    Type         = [System.IO.Path]::GetExtension($asset.browser_download_url).Split(".")[-1]
                                    Date         = ConvertTo-DateTime -DateTime $item.created_at -Pattern "MM/dd/yyyy HH:mm:ss"
                                    Size         = $asset.size
                                    URI          = $asset.browser_download_url
                                }
                                If ($PSObject.Platform -eq "Windows") {
                                    Write-Output -InputObject $PSObject
                                }
                            }
                            Else {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Skip: $($asset.browser_download_url)."
                            }
                        }
                    }
                }
            }
        }
    }
}
