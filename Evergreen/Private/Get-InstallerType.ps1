function Get-InstallerType {
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String] $String
    )

    switch -Regex ($String.ToLower()) {
        "user"          { $Type = "User"; break }
        "portable"      { $Type = "Portable"; break }
        "no-installer"  { $Type = "Portable"; break }
        "debug"         { $Type = "Debug"; break }
        default {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Installer type not found in $String, defaulting to 'Default'."
            $Type = "Default"
        }
    }
    Write-Output -InputObject $Type
}
