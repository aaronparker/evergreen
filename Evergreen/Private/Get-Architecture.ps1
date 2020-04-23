Function Get-Architecture {
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $String
    )

    Switch -Regex ($String) {
        "amd64" { $architecture = "AMD64" }
        "arm64" { $architecture = "ARM64" }
        "arm32" { $architecture = "ARM32" }
        "x86_64" { $architecture = "x86_64" }
        "x64" { $architecture = "x64" }
        "-x86" { $architecture = "x86" }
        "fxdependent" { $architecture = "fxdependent" }
        Default {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Architecture not found, defaulting to x86."
            $architecture = "x86"
        }
    }
    Write-Output -InputObject $architecture
}
