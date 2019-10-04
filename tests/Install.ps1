<#
    .SYNOPSIS
        AppVeyor tests setup script.
#>
# Line break for readability in AppVeyor console
Write-Host -Object ''
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.tostring()

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Pester -Force
Install-Module -Name PSScriptAnalyzer -SkipPublisherCheck -Force
Install-Module -Name posh-git -Force

# Import the module
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
Import-Module (Join-Path $projectRoot "Evergreen") -Verbose -Force
