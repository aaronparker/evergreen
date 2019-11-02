<#
    .SYNOPSIS
        AppVeyor install script.
#>
[OutputType()]
Param()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing 
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}
$tests = Join-Path $projectRoot "tests"
$output = Join-Path $projectRoot "TestsResults.xml"
$moduleParent = Join-Path -Path $projectRoot -ChildPath $module
$manifestPath = Join-Path -Path $moduleParent -ChildPath "$module.psd1"
$modulePath = Join-Path -Path $moduleParent -ChildPath "$module.psm1"

# Echo variables
Write-Host ""
Write-Host "ProjectRoot:     $projectRoot."
Write-Host "Module name:     $module."
Write-Host "Module parent:   $moduleParent."
Write-Host "Module manifest: $manifestPath."
Write-Host "Module path:     $modulePath."
Write-Host "Tests path:      $tests."
Write-Host "Output path:     $output."

# Line break for readability in AppVeyor console
Write-Host ""
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.ToString()

# Install packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208
If (Get-PSRepository -Name PSGallery | Where-Object { $_.InstallationPolicy -ne "Trusted" }) {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
If ([Version]((Find-Module -Name Pester).Version) -gt (Get-Module -Name Pester).Version) {
    Install-Module -Name Pester -SkipPublisherCheck -Force
}
If ([Version]((Find-Module -Name PSScriptAnalyzer).Version) -gt (Get-Module -Name PSScriptAnalyzer).Version) {
    Install-Module -Name PSScriptAnalyzer -SkipPublisherCheck -Force
}
If ([Version]((Find-Module -Name posh-git).Version) -gt (Get-Module -Name posh-git).Version) {
    Install-Module -Name posh-git -Force
}

# Import module
Write-Host ""
Write-Host "Importing module." -ForegroundColor Cyan
Import-Module $manifestPath -Force
