Function Get-SourceForgeRepoRelease {
    <#
        .SYNOPSIS
            Validates a JSON string returned from a SourceForge releases API and returns a formatted object
            Example: https://sourceforge.net/projects/sevenzip/best_release.json
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Download,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion
    )

    # Retrieve best release json
    $BestRelease = Invoke-RestMethodWrapper -Uri $Uri

    # Validate that $BestRelease has the expected properties
    Write-Verbose -Message "$($MyInvocation.MyCommand): Validating SourceForge release object."
    $params = @{
        ReferenceObject  = $script:resourceStrings.Properties.SourceForge
        DifferenceObject = (Get-Member -InputObject $BestRelease -MemberType NoteProperty)
        PassThru         = $true
        ErrorAction      = "SilentlyContinue"
    }
    $missingProperties = Compare-Object @params
    if ($null -ne $missingProperties) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Property validation succeeded."
    }
    else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Property validation failed."
        $missingProperties | ForEach-Object {
            throw [System.Management.Automation.ValidationMetadataException]::New("$($MyInvocation.MyCommand): Property: '$_' missing")
        }
    }

    # Find version number and the releases folder
    try {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Capture version number from: $($BestRelease.platform_releases.windows.filename)."
        $Filename = Split-Path -Path $BestRelease.platform_releases.windows.filename -Leaf
        $Folder = ($BestRelease.platform_releases.windows.filename -split $Filename)[0]
        $Version = [RegEx]::Match($Folder, $MatchVersion).Captures.Groups[1].Value
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found filename: [$Filename]."
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found folder:   [$Folder]."
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version:  [$Version]."
    }
    catch {
        throw "$($MyInvocation.MyCommand): Failed to find filename, folder, version number from: $($BestRelease.platform_releases.windows.filename)."
    }

    # Get the downloads XML feed and select the latest item via the $Version value
    $params = @{
        Uri         = "$($Download.Feed)$Folder"
        ContentType = $Download.ContentType
    }
    $Content = Invoke-RestMethodWrapper @params

    # Filter items for file types that we've included in the manifest
    $fileItems = $Content | Where-Object { ($_.link -replace $Download.ReplaceText.Link, "") -match $Download.MatchFileTypes }
    Write-Verbose -Message "$($MyInvocation.MyCommand): found $($fileItems.Count) items."

    # For each filtered file, build a release object
    foreach ($item in $fileItems) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): matched: $($item.link)."
        $Url = "$($Download.Uri)$($item.description.'#cdata-section')" -replace " ", "%20"
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Architecture = Get-Architecture -String $Url
            Type         = [System.IO.Path]::GetExtension($Url).Split(".")[-1]
            URI          = $Url
        }
        Write-Output -InputObject $PSObject
    }
}
