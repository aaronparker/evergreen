Function ConvertFrom-SourceForgeReleasesJson {
    <#
        .SYNOPSIS
            Validates a JSON string returned from a SourceForge releases API and returns a formatted object
            Example: https://api.SourceForge.com/repos/PowerShell/PowerShell/releases/latest
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

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DownloadUri,

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DatePattern = "yyyy-MM-dd HH:mm:ss"
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
        # Validate that $release has the expected properties
        Write-Verbose -Message "$($MyInvocation.MyCommand): Validating SourceForge release object."
        $requiredProperties = @("release", "platform_releases")
        $params = @{
            ReferenceObject  = $requiredProperties
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

        # Find version number
        try {
            $Version = [RegEx]::Match($release.release.filename, $MatchVersion).Captures.Groups[1].Value
        }
        catch {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to find version number."
            $Version = "Unknown"
        }

        # Build and array of the latest release and download URLs
        If ($validate) {

            # Construct the output; Return the custom object to the pipeline
            Write-Verbose -Message "$($MyInvocation.MyCommand): Building output object."
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Platform     = (Get-Platform -String $release.release.filename)
                Architecture = (Get-Architecture -String $release.release.filename)
                Date         = (ConvertTo-DateTime -DateTime $release.release.date -Pattern $DatePattern)
                Size         = $release.release.bytes
                Md5Hash      = $release.release.md5sum
                URI          = ("$DownloadUri$($release.release.filename)" -replace " ", "%20")
            }
            Write-Output -InputObject $PSObject
        }
    }
}
