<#
    .SYNOPSIS
        Evergreen script to initiate the module
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSReviewUnusedParameter", "", Justification="Required for argument completion.")]
[CmdletBinding(SupportsShouldProcess = $false)]
param ()

# Get public and private function definition files
$PublicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$PrivateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$SharedRoot = Join-Path -Path $PSScriptRoot -ChildPath "Shared"
$Public = @( Get-ChildItem -Path (Join-Path -Path $PublicRoot -ChildPath "*.ps1") -ErrorAction "SilentlyContinue" )
$Private = @( Get-ChildItem -Path (Join-Path -Path $PrivateRoot -ChildPath "*.ps1") -ErrorAction "SilentlyContinue" )
$Shared = @( Get-ChildItem -Path (Join-Path -Path $SharedRoot -ChildPath "*.ps1") -ErrorAction "SilentlyContinue" )

# Dot source the files
foreach ($Import in @($Public + $Private + $Shared)) {
    try {
        . $Import.FullName
    }
    catch {
        throw $_
    }
}

# Get module strings
$script:resourceStrings = Get-ModuleResource

# Register the argument completer for the Get-EvergreenApp and Find-EvergreenApp cmdlets
$Commands = "Get-EvergreenApp", "Find-EvergreenApp", "Get-EvergreenAppFromApi", "Export-EvergreenManifest", "Get-EvergreenLibraryApp", "Get-EvergreenEndpointFromApi"
Register-ArgumentCompleter -CommandName $Commands -ParameterName "Name" -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    (Get-ChildItem -Path "$PSScriptRoot\Manifests\$wordToComplete*.json" -ErrorAction "Ignore").BaseName
}

# Export the public modules and aliases
Export-ModuleMember -Function $public.Basename -Alias *
