Function Get-SourceForgeRepoRelease {
    <#
        .SYNOPSIS
            Validates a JSON string returned from a SourceForge releases API and returns a formatted object
            Example: https://sourceforge.net/projects/sevenzip/best_release.json
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Uri,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Download,

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion
    )

    # retrieve best release json
    try {
        $bestRelease = Invoke-RestMethodWrapper -Uri $Uri
    }
    catch {
        Throw "Failed to resolve update feed: $Uri."
        Break
    }

    # Validate that $bestRelease has the expected properties
    Write-Verbose -Message "$($MyInvocation.MyCommand): Validating SourceForge release object."
    $params = @{
        ReferenceObject  = $script:resourceStrings.Properties.SourceForge
        DifferenceObject = (Get-Member -InputObject $bestRelease -MemberType NoteProperty)
        PassThru         = $True
        ErrorAction      = $script:resourceStrings.Preferences.ErrorAction
    }
    $missingProperties = Compare-Object @params
    If ($Null -ne $missingProperties) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Validated successfully."
        #$validate = $True
    }
    Else {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Validation failed."
        #$validate = $False
        $missingProperties | ForEach-Object {
            Throw [System.Management.Automation.ValidationMetadataException] "$($MyInvocation.MyCommand): Property: '$_' missing"
        }
    }

    # Find version number
    try {
        $Version = [RegEx]::Match($bestRelease.platform_releases.windows.filename, $MatchVersion).Captures.Groups[1].Value
    }
    catch {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to find version number."
        $Version = "Unknown"
    }

    # Get the downloads XML feed
    $iwcParams = @{
        Uri         = "$($Download.Feed)/$($Download.Folder)"
        ContentType = $Download.ContentType
        Raw         = $True
    }
    $Content = Invoke-WebRequestWrapper @iwcParams

    # Convert to an XML object
    Try {
        [System.XML.XMLDocument] $xmlDocument = $Content
    }
    Catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
    }
        
    # Select the required node/s from the XML feed
    $nodes = Select-Xml -Xml $xmlDocument -XPath $Download.XPath | Select-Object –ExpandProperty "node"
    $fileItems = $nodes | Select-Object -ExpandProperty $Download.FilterProperty | Where-Object { $_ -match $Version }

    ForEach ($item in $fileItems) {
        try {
            $File = [RegEx]::Match($item, "$Version/$($script:resourceStrings.Filters.Filename)").Captures.Groups[1].Value
        }
        catch {
            $File = $Null
        }
        If ($Null -ne $File) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): matched: $item."
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = Get-Architecture -String $File
                URI          = "$($Download.Uri)/$($Download.Folder)/$Version/$File" -replace " ", "%20"
            }
            Write-Output -InputObject $PSObject
        }
    }
}
