Function ConvertTo-DateTime {
    <#
        .SYNOPSIS
            Return a date/time string converted to a localised short date string.
    #>
    [OutputType([System.DateTime])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $DateTime,

        [Parameter(Position = 1)]
        [System.String] $Pattern = 'MM/dd/yyyy'
    )

    # Convert the date/time passed to the function. If conversion fails, pass the same string back
    try {
        $ConvertedDateTime = [DateTime]::ParseExact($DateTime, $Pattern, [System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat)
        $Output = $ConvertedDateTime.ToShortDateString()
    }
    catch {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Failed to convert to short date."
        $Output = [DateTime] $DateTime
    }
    
    # Write the output to the pipeline
    Write-Verbose -Message "$($MyInvocation.MyCommand): Returning date: [$Output]."
    Write-Output -InputObject $Output
}
