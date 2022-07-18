<#
    .SYNOPSIS
        AppVeyor tests script.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[OutputType()]
param ()

if (Test-Path -Path "env:APPVEYOR_BUILD_FOLDER") {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = Split-Path -Path $projectRoot -Leaf
}

$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
$WarningPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

if (Get-Variable -Name "projectRoot" -ErrorAction "SilentlyContinue") {

    $CodeCoverage = "$projectRoot\tests\CodeCoverage.xml"
    $TestResults = "$projectRoot\tests\TestResults.xml"
    $CodeCov = "$projectRoot\tests\codecov.exe"

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
    if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed." }

    Write-Host ""
    if (Test-Path -Path env:APPVEYOR_JOB_ID) {

        if (Test-Path -Path $TestResults) {
            Write-Host "Found: $TestResults."
            $WebClient = New-Object -TypeName "System.Net.WebClient"
            $WebClient.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path -Path $TestResults))
        }
        else {
            Write-Host "Can't find: $TestResults."
        }

        if (Test-Path -Path $CodeCoverage) {
            Write-Host "Found: $CodeCoverage."
            Invoke-WebRequest -Uri https://uploader.codecov.io/latest/windows/codecov.exe -OutFile $CodeCov -UseBasicParsing
            . $CodeCov -t $env:CODECOV_TOKEN -f $CodeCoverage
            Remove-Item -Path $CodeCov -Force
        }
        else {
            Write-Host "Can't find: $CodeCoverage."
        }
    }
    else {
        Write-Warning -Message "Cannot find: APPVEYOR_JOB_ID"
    }
}
else {
    Write-Warning -Message "Required variable does not exist: projectRoot."
}

# Line break for readability in AppVeyor console
Write-Host ""
