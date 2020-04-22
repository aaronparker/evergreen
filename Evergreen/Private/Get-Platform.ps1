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
        "\.rpm" { $platform = "RedHat" }
        "\.tar.gz|linux" { $platform = "Linux" }
        "\.nupkg" { $platform = "NuGet" }
        "mac|osx" { $platform = "macOS" }
        "\.deb|debian" { $platform = "Debian" }
        "ubuntu" { $platform = "Ubuntu" }
        "centos" { $platform = "CentOS" }
        "\.exe|\.msi|windows|win" { $platform = "Windows" }
        Default {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Platform not found, defaulting to Windows."
            $platform = "Windows"
        }
    }
    Write-Output -InputObject $platform
}
