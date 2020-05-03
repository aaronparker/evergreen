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
        [System.String] $MatchVersion
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
        # Ensure that we only have the latest release
        If ($release.Count -gt 1) {
            try {
                Write-Warning -Message "$($MyInvocation.MyCommand): More than one release retrieved from GitHub."
                $release = $release | Where-Object { $_.prerelease -eq $False } | Select-Object -First 1
            }
            catch {
                Throw [System.Management.Automation.RuntimeException] "$($MyInvocation.MyCommand): Failed to filter to latest release."
            }
        }

        # Validate that $release has the expected properties
        Write-Verbose -Message "$($MyInvocation.MyCommand): Validating GitHub release object."
        $params = @{
            ReferenceObject  = $script:resourceStrings.Properties.GitHub
            DifferenceObject = (Get-Member -InputObject $release -MemberType NoteProperty)
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

        # Build and array of the latest release and download URLs
        If ($validate) {
            ForEach ($asset in $release.assets) {
                If ($asset.browser_download_url -match $script:resourceStrings.Filters.WindowsInstallers) {
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Building output object."
                    $PSObject = [PSCustomObject] @{
                        Version      = [RegEx]::Match($release.tag_name, $MatchVersion).Captures.Groups[1].Value
                        Platform     = (Get-Platform -String $asset.browser_download_url)
                        Architecture = (Get-Architecture -String $asset.browser_download_url)
                        Date         = ConvertTo-DateTime -DateTime $release.created_at
                        Size         = $asset.size
                        URI          = $asset.browser_download_url
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
}
