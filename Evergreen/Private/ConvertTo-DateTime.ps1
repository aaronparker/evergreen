Function ConvertTo-DateTime {
    <#
        .SYNOPSIS
            Return string converted to date/time with formatting accounting for Windows PowerShell or PowerShell Core
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

    # Return formatted DateTime if we're running on PowerShell Core vs. Windows PowerShell
    # There's likely a better way to do this, but this is a start
    try {
        If (Test-PSCore) {
            $Output = [DateTime]::ParseExact($DateTime, $Pattern, [CultureInfo]::InvariantCulture)
        }
        Else {
            $Output = [DateTime]::Parse($DateTime)
        }
    }
    catch {
        $Output = $DateTime
    }
    
    # Write the output to the pipeline
    Write-Output -InputObject $Output
}
