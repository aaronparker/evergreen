<#
    .SYNOPSIS
        AppVeyor install script.
#>
[OutputType()]
param ()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
    $source = $env:Source
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}
$moduleParent = Join-Path -Path $projectRoot -ChildPath $source
$manifestPath = Join-Path -Path $moduleParent -ChildPath "$module.psd1"
$modulePath = Join-Path -Path $moduleParent -ChildPath "$module.psm1"

# Echo variables
Write-Host ""
Write-Host "ProjectRoot:     $projectRoot."
Write-Host "Module name:     $module."
Write-Host "Module parent:   $moduleParent."
Write-Host "Module manifest: $manifestPath."
Write-Host "Module path:     $modulePath."

# Line break for readability in AppVeyor console
Write-Host ""
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.ToString()

# Import module
Write-Host ""
Write-Host "Importing module." -ForegroundColor "Cyan"
Import-Module $manifestPath -Force

# Install packages
Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208"
If (Get-PSRepository -Name "PSGallery" | Where-Object { $_.InstallationPolicy -ne "Trusted" }) {
    Write-Host "Trust repository: PSGallery." -ForegroundColor "Cyan"
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
}
$Modules = @("Pester", "PSScriptAnalyzer", "posh-git", "MarkdownPS")
ForEach ($Module in $Modules) {
    If ([System.Version]((Find-Module -Name $Module).Version) -gt (Get-Module -Name $Module -ListAvailable).Version) {
        Write-Host "Checking module $Module." -ForegroundColor "Cyan"
        Install-Module -Name $Module -SkipPublisherCheck -Force
        Import-Module -Name $Module -Force
    }
}
