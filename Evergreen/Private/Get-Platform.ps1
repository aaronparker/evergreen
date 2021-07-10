Function Get-Platform {
    [OutputType([System.String])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $String
    )

    Switch -Regex ($String) {
        "rhel" { $platform = "RHEL"; Break }
        "\.rpm" { $platform = "RedHat"; Break }
        "\.tar.gz|linux" { $platform = "Linux"; Break }
        "\.nupkg" { $platform = "NuGet"; Break }
        "macos|osx|darwin" { $platform = "macOS"; Break }
        "\.deb|debian" { $platform = "Debian"; Break }
        "ubuntu" { $platform = "Ubuntu"; Break }
        "centos" { $platform = "CentOS"; Break }
        "\.exe|\.msi|windows|win" { $platform = "Windows"; Break }
        Default {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Platform not found, defaulting to Windows."
            $platform = "Windows"
        }
    }
    Write-Output -InputObject $platform
}
