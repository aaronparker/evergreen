<#
    .SYNOPSIS
        Run local Pester tests avoiding large downloads
#>
[OutputType()]
Param()

# Invoke Pester tests and upload results to AppVeyor
Invoke-Pester -Path (Join-Path -Path $PWD -ChildPath "*.Tests.ps1") -PassThru #-ExcludeTag "AppVeyor"
Write-Host ""
