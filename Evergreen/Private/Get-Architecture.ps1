Function Get-Architecture {
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $String
    )

    Switch -Regex ($String.ToLower()) {
        "amd64" { $architecture = "AMD64"; Break }
        "arm64" { $architecture = "ARM64"; Break }
        "arm32" { $architecture = "ARM32"; Break }
        "arm" { $architecture = "ARM32"; Break }
        "win64" { $architecture = "x64"; Break }
        "win32" { $architecture = "x86"; Break }
        "x86_64" { $architecture = "x64"; Break }
        "x64" { $architecture = "x64"; Break }
        "w64" { $architecture = "x64"; Break }
        "-64" { $architecture = "x64"; Break }
        "64-bit" { $architecture = "x64"; Break }
        "64bit" { $architecture = "x64"; Break }
        "32-bit" { $architecture = "x86"; Break }
        "32bit" { $architecture = "x86"; Break }
        "x32" { $architecture = "x86"; Break }
        "w32" { $architecture = "x86"; Break }
        "-32" { $architecture = "x86"; Break }
        "-x86" { $architecture = "x86"; Break }
        "x86" { $architecture = "x86"; Break }
        Default {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Architecture not found in $String, defaulting to x86."
            $architecture = "x86"
        }
    }
    Write-Output -InputObject $architecture
}
