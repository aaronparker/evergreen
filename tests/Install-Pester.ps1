<#
    Install the latest version of Pester
#>

# Trust the PSGallery for modules
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208" -ErrorAction "SilentlyContinue"
Install-PackageProvider -Name "PowerShellGet" -MinimumVersion "2.2.5" -ErrorAction "SilentlyContinue"
if (Get-PSRepository | Where-Object { $_.Name -eq $Repository -and $_.InstallationPolicy -ne "Trusted" }) {
    Set-PSRepository -Name $Repository -InstallationPolicy "Trusted"
}

foreach ($module in "Pester") {
    $installedModule = Get-Module -Name $module -ListAvailable -ErrorAction "SilentlyContinue" | `
        Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } -ErrorAction "SilentlyContinue" | `
        Select-Object -First 1
    $publishedModule = Find-Module -Name $module -ErrorAction "SilentlyContinue"
    if (($null -eq $installedModule) -or ([System.Version]$publishedModule.Version -gt [System.Version]$installedModule.Version)) {
        $params = @{
            Name               = $module
            SkipPublisherCheck = $true
            ErrorAction        = "Stop"
        }
        Install-Module @params
    }
}
