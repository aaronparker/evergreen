Function Get-Platform {
    [OutputType([System.String])]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $String
    )

    Switch -Regex ($String) {
        "rhel" { $platform = "RHEL" }
        "linux" { $platform = "Linux" }
        "win" { $platform = "Windows" }
        "osx" { $platform = "macOS" }
        "debian" { $platform = "Debian" }
        "ubuntu" { $platform = "Ubuntu" }
        "centos" { $platform = "CentOS" }
        Default { $platform = "Unknown" }
    }
    Write-Verbose -Message "$($MyInvocation.MyCommand): Found $platform."
    Write-Output -InputObject $platform
}
