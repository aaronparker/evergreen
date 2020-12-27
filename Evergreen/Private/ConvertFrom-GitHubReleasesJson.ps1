Function ConvertFrom-GitHubReleasesJson {
    <#
        .SYNOPSIS
            Validates a JSON string returned from a GitHub releases API and returns a formatted object
            Example: https://api.github.com/repos/PowerShell/PowerShell/releases/latest
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Content,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $VersionTag = "tag_name"
    )

    # Convert JSON string to a hashtable
    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Converting from JSON string."
        $release = ConvertFrom-Json -InputObject $Content
    }
    catch {
        Throw [System.Management.Automation.RuntimeException] "$($MyInvocation.MyCommand): Failed to convert JSON string."
        Break
    }
    finally {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found $($release.count) releases."

        # Validate that $release has the expected properties
        Write-Verbose -Message "$($MyInvocation.MyCommand): Validating GitHub release object."
        ForEach ($item in $release) {
            $params = @{
                ReferenceObject  = $script:resourceStrings.Properties.GitHub
                DifferenceObject = (Get-Member -InputObject $item -MemberType NoteProperty)
                PassThru         = $True
                ErrorAction      = $script:resourceStrings.Preferences.ErrorAction
            }
            $missingProperties = Compare-Object @params
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
                    If ($asset.browser_download_url -match $script:resourceStrings.Filters.WindowsInstallers) {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Building Windows release output object with: $asset.browser_download_url."

                        try {
                            $version = [RegEx]::Match($item.$VersionTag, $MatchVersion).Captures.Groups[1].Value
                        }
                        catch {
                            $version = $item.$VersionTag
                        }

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
                }
            }
        }
    }
}
