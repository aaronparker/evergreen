<#
    .SYNOPSIS
        Main Pester function tests.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[OutputType()]
param ()

BeforeDiscovery {
    # TestCases are splatted to the script so we need hashtables
    $scripts = Get-ChildItem -Path $moduleParent -Recurse -Include *.ps1, *.psm1
    $testCase = $scripts | ForEach-Object { @{file = $_ } }

    # Get the ScriptAnalyzer rules
    $scriptAnalyzerRules = Get-ScriptAnalyzerRule

    # Find module scripts to create the test cases
    $scripts = Get-ChildItem -Path $moduleParent -Recurse -Include *.ps1
    $testCase = $scripts | ForEach-Object { @{file = $_ } }
}

Describe "General project validation" {
    It "Script <file.Name> should be valid PowerShell" -TestCases $testCase {
        param ($file)

        $file.FullName | Should -Exist

        $contents = Get-Content -Path $file.FullName -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should -Be 0
    }

    It "Script <file.Name> should pass ScriptAnalyzer" -TestCases $testCase {
        param ($file)
        $analysis = Invoke-ScriptAnalyzer -Path $file.FullName -ExcludeRule @('PSAvoidGlobalVars', 'PSAvoidUsingWMICmdlet') -Severity @('Warning', 'Error')

        ForEach ($rule in $scriptAnalyzerRules) {
            If ($analysis.RuleName -contains $rule) {
                $analysis |
                Where-Object RuleName -EQ $rule -OutVariable failures |
                Out-Default
                $failures.Count | Should -Be 0
            }
        }
    }
}

Describe "Module Function validation" {
    It "Script <file.Name> should only contain one function" -TestCases $testCase {
        param ($file)
        $file.FullName | Should -Exist
        $contents = Get-Content -Path $file.FullName -ErrorAction Stop
        $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
        $test = $describes.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        $test.Count | Should -Be 1
    }

    It "Script <file.Name> should match function name" -TestCases $testCase {
        param ($file)
        $file.FullName | Should -Exist
        $contents = Get-Content -Path $file.FullName -ErrorAction Stop
        $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
        $test = $describes.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        $test[0].name | Should -Be $file.basename
    }
}

# Test module and manifest
Describe "Module Metadata validation" {
    It "Script fileinfo should be OK" {
        { Test-ModuleManifest -Path $manifestPath -ErrorAction Stop } | Should -Not -Throw
    }

    It "Import module should be OK" {
        { Import-Module $modulePath -Force -ErrorAction Stop } | Should -Not -Throw
    }
}
