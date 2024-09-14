function Get-GitHubRepoTag {
    <#
        .SYNOPSIS
            Calls the GitHub Tags API passed via $Uri, validates the response and returns a formatted object
            Example: https://api.github.com/repos/PowerShell/PowerShell/releases/latest

            TODO: support Basic or OAuth authentication to GitHub
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript( {
                if ($_ -match "^(https://api\.github\.com/repos/)([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)(/tags)") {
                    $true
                }
                else {
                    throw "'$_' must be in the format 'https://api.github.com/repos/user/repository/tags'. Replace 'user' with the user or organisation and 'repository' with the target repository name."
                }
            })]
        [System.String] $Uri,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion = "(\d+(\.\d+){1,4}).*",

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VersionTag = "tag_name",

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Filter = "\.exe$|\.msi$|\.msp$|\.zip$",

        [Parameter(Mandatory = $false, Position = 4)]
        [System.Array] $VersionReplace,

        [Parameter()]
        [System.Management.Automation.SwitchParameter] $ReturnVersionOnly
    )

    begin {
        $RateLimit = Get-GitHubRateLimit
    }

    process {
        if ($RateLimit.remaining -eq 0) {
            # We're rate limited, so output a special object
            [PSCustomObject] @{
                Version = "RateLimited"
                URI     = "https://docs.github.com/en/rest/overview/resources-in-the-rest-api#rate-limiting"
            } | Write-Output
        }
        else {
            try {
                # Retrieve the releases from the GitHub API
                # Use TLS for connections
                Write-Verbose -Message "$($MyInvocation.MyCommand): Set TLS to 1.2."
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

                # Invoke the GitHub releases REST API
                # Note that the API performs rate limiting.
                # https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#get-the-latest-release
                $params = @{
                    ContentType        = "application/vnd.github.v3+json"
                    ErrorAction        = "Stop"
                    MaximumRedirection = 0
                    DisableKeepAlive   = $true
                    UseBasicParsing    = $true
                    UserAgent          = "github-aaronparker-evergreen"
                    Uri                = $Uri
                }
                if (Test-ProxyEnv) {
                    $params.Proxy = $script:EvergreenProxy
                }
                if (Test-ProxyEnv -Creds) {
                    $params.ProxyCredential = $script:EvergreenProxyCreds
                }
                # If GITHUB_TOKEN or GH_TOKEN exists, let's add that to the API request
                if (Test-Path -Path "env:GITHUB_TOKEN") {
                    $params.Headers = @{ Authorization = "token $env:GITHUB_TOKEN" }
                }
                elseif (Test-Path -Path "env:GH_TOKEN") {
                    $params.Headers = @{ Authorization = "token $env:GH_TOKEN" }
                }

                # Output the parameters when using -Verbose
                foreach ($tag in $params.GetEnumerator()) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Invoke-WebRequest parameter: $($tag.name): $($tag.value)."
                }

                Write-Verbose -Message "$($MyInvocation.MyCommand): Get GitHub release from: $Uri."
                $tags = Invoke-RestMethod @params
            }
            catch {
                throw $_
            }

            if ($null -eq $script:resourceStrings.Properties.GitHub) {
                Write-Warning -Message "$($MyInvocation.MyCommand): Unable to validate tag against GitHub releases property object because we can't find the module resource."
            }
            else {
                # Validate that $tags has the expected properties
                Write-Verbose -Message "$($MyInvocation.MyCommand): Validating GitHub tag object."
                foreach ($tag in $tags) {

                    # Compare the GitHub release object with properties that we expect
                    $params = @{
                        ReferenceObject  = $script:resourceStrings.Properties.GitHubTags
                        DifferenceObject = (Get-Member -InputObject $tag -MemberType NoteProperty)
                        PassThru         = $true
                        ErrorAction      = "Continue"
                    }
                    $missingProperties = Compare-Object @params

                    # Throw an error for missing properties
                    if ($null -ne $missingProperties) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Validated successfully."
                    }
                    else {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Validation failed."
                        $missingProperties | ForEach-Object {
                            throw [System.Management.Automation.ValidationMetadataException]::New("$($MyInvocation.MyCommand): Property: '$_' missing")
                        }
                    }
                }
            }

            # Build and array of the latest release and download URLs
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($tags.count) tags."
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($tags.assets.count) asset/s."

            if ($PSBoundParameters.ContainsKey("ReturnVersionOnly")) {
                if ($Uri -match "^*tags$") {
                    try {
                        # Uri matches tags fo the repo; find the latest tag
                        $Version = [RegEx]::Match($tags[0].name, $MatchVersion).Captures.Groups[1].Value
                    }
                    catch {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number as-is, returning: $($tags[0].$VersionTag)."
                        $Version = $tags[0].name
                    }
                }
                else {
                    try {
                        # Uri matches releases for the repo; return just the version string
                        $Version = [RegEx]::Match($tags[0].$VersionTag, $MatchVersion).Captures.Groups[1].Value
                    }
                    catch {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number as-is, returning: $($tags[0].$VersionTag)."
                        $Version = $tag.$VersionTag
                    }
                }

                if ($PSBoundParameters.ContainsKey("VersionReplace")) {
                    # Replace string in version
                    $Version = $Version -replace $res.Get.VersionReplace[0], $res.Get.VersionReplace[1]
                }

                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version = $Version
                }
                Write-Output -InputObject $PSObject
            }
            else {
                foreach ($tag in $tags) {
                    foreach ($asset in $tag.assets) {

                        # Filter downloads by matching the RegEx in the manifest. The the RegEx may perform includes and excludes
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Match $Filter to $($asset.browser_download_url)."
                        if ($asset.browser_download_url -match $Filter) {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Building Windows release output object with: $($asset.browser_download_url)."

                            # Capture the version string from the specified release tag
                            try {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Matching version number against: $($tag.$VersionTag)."
                                $Version = [RegEx]::Match($tag.$VersionTag, $MatchVersion).Captures.Groups[1].Value
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version number: $Version."
                            }
                            catch {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to match version number, returning: $($tag.$VersionTag)."
                                $Version = $tag.$VersionTag
                            }

                            if ($PSBoundParameters.ContainsKey("VersionReplace")) {
                                # Replace string in version
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Replace $($res.Get.VersionReplace[0])."
                                $Version = $Version -replace $res.Get.VersionReplace[0], $res.Get.VersionReplace[1]
                            }

                            # Build the output object
                            if ((Get-Platform -String $asset.browser_download_url) -eq "Windows") {
                                $PSObject = [PSCustomObject] @{
                                    Version       = $Version
                                    Date          = ConvertTo-DateTime -DateTime $tag.created_at -Pattern "MM/dd/yyyy HH:mm:ss"
                                    Size          = $asset.size
                                    #Platform      = Get-Platform -String $asset.browser_download_url
                                    Architecture  = Get-Architecture -String $(Split-Path -Path $asset.browser_download_url -Leaf)
                                    InstallerType = Get-InstallerType -String $asset.browser_download_url
                                    Type          = [System.IO.Path]::GetExtension($asset.browser_download_url).Split(".")[-1]
                                    URI           = $asset.browser_download_url
                                }
                                Write-Output -InputObject $PSObject
                            }
                        }
                        else {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Skip: $($asset.browser_download_url)."
                        }
                    }
                }
            }
        }
    }
}
