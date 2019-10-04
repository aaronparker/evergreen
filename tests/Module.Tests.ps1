$ModuleName = "Evergreen"

# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing 
    $ProjectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
$manifest = Join-Path (Join-Path $ProjectRoot $ModuleName) "$ModuleName.psd1"
$module = Join-Path (Join-Path $ProjectRoot $ModuleName) "$ModuleName.psm1"

Write-Host "Manifest is: $($manifest)"
Write-Host "Module is: $($module)"

Describe 'Module Metadata Validation' {      
    It 'Script fileinfo should be OK' {
        { Test-ModuleManifest $manifest -ErrorAction Stop } | Should Not Throw
    }
        
    It 'Import module should be OK' {
        { Import-Module $module -Force -ErrorAction Stop } | Should Not Throw
    }
}
