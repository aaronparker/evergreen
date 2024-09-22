function ConvertTo-DotNetVersionClass {
    <#
        .SYNOPSIS
        Converts a version string to a standard .NET compliant Version class.

        .DESCRIPTION
        The ConvertTo-DotNetVersionClass function takes a version string as input and converts it into a .NET Version class. 
        It normalizes the segments of the version string, ensuring it has exactly four segments by either summing excess segments 
        or padding with zeros if there are fewer than four segments.

        .PARAMETER Version
        A version string to convert to a standard .NET compliant version class.

        .EXAMPLE
        PS> ConvertTo-DotNetVersionClass -Version "1.2.3.4"
        1.2.3.4

        .EXAMPLE
        PS> ConvertTo-DotNetVersionClass -Version "1.2.3"
        1.2.3.0

        .EXAMPLE
        PS> ConvertTo-DotNetVersionClass -Version "1.2.3.4.5"
        1.2.3.9

        .NOTES
        If the conversion to a .NET Version class fails, the function will return the normalized version string as a string.
    #>
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
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
