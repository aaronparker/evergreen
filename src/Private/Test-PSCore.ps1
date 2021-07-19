Function Test-PSCore {
    <#
        .SYNOPSIS
            Returns True if running on PowerShell Core.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([Boolean])]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Version = '6.0.0'
    )

    # Check whether current PowerShell environment matches or is higher than $Version
    If (($PSVersionTable.PSVersion -ge [Version]::Parse($Version)) -and ($PSVersionTable.PSEdition -eq "Core")) {
        Write-Output -InputObject $True
    }
    Else {
        Write-Output -InputObject $False
    }
}
