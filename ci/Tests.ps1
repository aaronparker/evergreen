<#
    .SYNOPSIS
        AppVeyor tests script.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[OutputType()]
param ()

If (Test-Path -Path "env:APPVEYOR_BUILD_FOLDER") {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}

# $moduleParent = Join-Path -Path $projectRoot -ChildPath $source
# $manifestPath = Join-Path -Path $moduleParent -ChildPath "$module.psd1"
# $modulePath = Join-Path -Path $moduleParent -ChildPath "$module.psm1"
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
$WarningPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

If (Get-Variable -Name "projectRoot" -ErrorAction "SilentlyContinue") {

    $CodeCoverage = "$projectRoot\tests\CodeCoverage.xml"
    $TestResults = "$projectRoot\tests\TestResults.xml"

    # Invoke Pester tests
    $Config = [PesterConfiguration]::Default
    $Config.Run.Path = "$projectRoot\tests"
    $Config.Run.PassThru = $True
    $Config.CodeCoverage.Enabled = $True
    $Config.CodeCoverage.Path = "$projectRoot\Evergreen"
    $Config.CodeCoverage.OutputFormat = "JaCoCo"
    $Config.CodeCoverage.OutputPath = $CodeCoverage
    $Config.TestResult.Enabled = $True
    $Config.TestResult.OutputFormat = "NUnitXml"
    $Config.TestResult.OutputPath = $TestResults
    $res = Invoke-Pester -Configuration $Config

    # Upload test results to AppVeyor
    If ($res.FailedCount -gt 0) { Throw "$($res.FailedCount) tests failed." }
    If (Test-Path -Path env:APPVEYOR_JOB_ID) {
        (New-Object -TypeName "System.Net.WebClient").UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path -Path $TestResults))

        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri https://uploader.codecov.io/latest/windows/codecov.exe -Outfile "$projectRoot\tests\codecov.exe"
        . "$projectRoot\tests\codecov.exe" -t $env:CODECOV_TOKEN -f $CodeCoverage
        Remove-Item -Path "$projectRoot\tests\codecov.exe" -Force
    }
    Else {
        Write-Warning -Message "Cannot find: APPVEYOR_JOB_ID"
    }
}
Else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}

# Line break for readability in AppVeyor console
Write-Host ""
