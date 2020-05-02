Function ConvertTo-DateTime {
    <#
        .SYNOPSIS
            Return a date/time string converted to a localised short date string.
    #>
    [OutputType([System.DateTime])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DateTime,

        [Parameter(Position = 1)]
        [System.String] $Pattern = 'MM/dd/yyyy HH:mm:ss'
    )

    # Convert the date/time passed to the function. If conversion fails, pass the same string back
    try {
        $ConvertedDateTime = [DateTime]::ParseExact($DateTime, $Pattern, [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat)
        $Output = $ConvertedDateTime.ToShortDateString()
    }
    catch {
        $Output = $DateTime
    }
    
    # Write the output to the pipeline
    Write-Output -InputObject $Output
}
