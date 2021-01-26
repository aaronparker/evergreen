Function Get-GitHubRepoRelease {
    <#
        .SYNOPSIS
            Calls the GitHub Releases API passed via $Uri, validates the response and returns a formatted object
            Example: https://api.github.com/repos/PowerShell/PowerShell/releases/latest
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateScript( {
                If ($_ -match "^(https://api\.github\.com/repos/)([a-zA-Z0-9_-]+)/([a-zA-Z0-9_-]+)(/releases)") {
                    $True
                }
                else {
                    Throw "'$_' must be in the format 'https://api.github.com/repos/user/repository/releases/latest'. Replace 'user' with the user or organisation and 'repository' with the target repository name."
                }
            })]
        [System.String] $Uri,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VersionTag = "tag_name",

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Filter = "\.exe$|\.msi$|\.msp$|\.zip$"
    )

    # Retrieve the releases from the GitHub API 
    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Get GitHub release from: $Uri."
        
        # Set TLS1.2 and a temp file for passthrough output
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $tempFile = New-TemporaryFile
        Write-Verbose -Message "$($MyInvocation.MyCommand): Using temp file $tempFile."
        
        # Invoke the GitHub releases REST API
        # Note that the API performs rate limiting. 
        # https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#get-the-latest-release
        $params = @{
            ContentType = "application/vnd.github.v3+json"
            Method      = "Get"
            Uri         = $Uri
        }
        $release = Invoke-RestMethodWrapper @params
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): REST API call to [$Uri] failed with: $($_.Exception.Response.StatusCode)."
        Throw $_
        Break
    }
    finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($release.count) releases."

        # Validate that $release has the expected properties
        Write-Verbose -Message "$($MyInvocation.MyCommand): Validating GitHub release object."
        ForEach ($item in $release) {

            # Compare the GitHub release object with properties that we expect
            $params = @{
                ReferenceObject  = $script:resourceStrings.Properties.GitHub
                DifferenceObject = (Get-Member -InputObject $item -MemberType NoteProperty)
                PassThru         = $True
                ErrorAction      = $script:resourceStrings.Preferences.ErrorAction
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

        # Build and array of the latest release and download URLs
        If ($validate) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($release.assets.count) assets."
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
                            Date         = ConvertTo-DateTime -DateTime $item.created_at
                            Size         = $asset.size
                            URI          = $asset.browser_download_url
                        }
                        Write-Output -InputObject $PSObject
                    }
                    Else {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Skip: $($asset.browser_download_url)."
                    }
                }
            }
        }
    }
}
