Function ConvertFrom-SourceForgeReleasesJson {
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
        [System.String] $Content,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Hashtable] $Download,

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [System.String] $MatchVersion,

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

    # Validate that $release has the expected properties
    Write-Verbose -Message "$($MyInvocation.MyCommand): Validating SourceForge release object."
    $params = @{
        ReferenceObject  = $script:resourceStrings.Properties.SourceForge
        DifferenceObject = (Get-Member -InputObject $release -MemberType NoteProperty)
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
        $Version = [RegEx]::Match($release.platform_releases.windows.filename, $MatchVersion).Captures.Groups[1].Value
    }
    catch {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to find version number."
        $Version = "Unknown"
    }

    # Get the downloads XML feed
    $iwcParams = @{
        Uri         = $Download.Feed
        ContentType = $Download.ContentType
        Raw         = $True
    }
    $Content = Invoke-WebContent @iwcParams

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
            #Write-Verbose -Message "$($MyInvocation.MyCommand): not a file we want: $File."
        }
        If ($File) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): matched: $item."
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = Get-Architecture -String $File
                URI          = "$($Download.Uri)/$Version/$File" -replace " ", "%20"
            }
            Write-Output -InputObject $PSObject
            Remove-Variable -Name File
        }
    }
}
