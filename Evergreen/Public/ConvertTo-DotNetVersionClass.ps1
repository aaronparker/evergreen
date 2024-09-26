function ConvertTo-DotNetVersionClass {
    <#
        .EXTERNALHELP Evergreen-help.xml
    #>
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "A version string to convert to a standard .NET compliant version class.")]
        [System.String] $Version
    )

    process {
        # Split the version string into segments and initialise an array
        $Segments = $Version -split '[.\-_+]'
        $NormalizedSegments = @()

        # Normalize each segment
        foreach ($Segment in $Segments) {
            $NormalizedSegments += @(Convert-Segment -Segment $Segment)
        }

        # If the number of segments is greater than 4, sum the last segments
        if ($NormalizedSegments.Count -gt 4) {
            $NormalizedSegments = $NormalizedSegments[0..2] + ($NormalizedSegments[3..($NormalizedSegments.Count - 1)] | Measure-Object -Sum).Sum
        }

        # If the number of segments is less than 4, pad with zeros
        while ($NormalizedSegments.Count -lt 4) {
            $NormalizedSegments += 0
        }

        # Return the version as a .NET Version class
        try {
            return [System.Version]($NormalizedSegments -join ".")
        }
        catch {
            Write-Warning -Message "Failed to convert version string '$Version' to a .NET Version class."
            return ($NormalizedSegments -join ".")
        }
    }
}
