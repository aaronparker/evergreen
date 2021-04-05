<#
    .SYNOPSIS
        AppVeyor tests script.
#>
[OutputType()]
param ()

If (Get-Variable -Name projectRoot -ErrorAction SilentlyContinue) {

    # Invoke Pester tests and upload results to AppVeyor
    $testsPath = Join-Path -Path $projectRoot -ChildPath "tests"
    $testOutput = Join-Path -Path $projectRoot -ChildPath "TestsResults.xml"
    $testConfig = [PesterConfiguration]@{
        Run        = @{
            Path     = $testsPath
            PassThru = $True
        }
        TestResult = @{
            OutputFormat = "NUnitXml"
            OutputFile   = $testOutput
        }
        Output     = @{
            Verbosity = "Detailed"
        }
    }
    #$res = Invoke-Pester -Path $testsPath -OutputFormat NUnitXml -OutputFile $testOutput -PassThru
    $res = Invoke-Pester -Configuration $testConfig

    If ($res.FailedCount -gt 0) { Throw "$($res.FailedCount) tests failed." }
    If (Test-Path -Path env:APPVEYOR_JOB_ID) {
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path -Path $testOutput))
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
