<#
    .SYNOPSIS
        Evergreen script to initiate the module
#>
[CmdletBinding(SupportsShouldProcess = $False)]
param ()

#region Get public and private function definition files
$publicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$privateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$Public = @( Get-ChildItem -Path (Join-Path $publicRoot "*.ps1") -ErrorAction "SilentlyContinue" )
$Private = @( Get-ChildItem -Path (Join-Path $privateRoot "*.ps1") -ErrorAction "SilentlyContinue" )

# Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        throw $_
    }
}

# Export the public modules and aliases
Export-ModuleMember -Function $public.Basename -Alias *
#endregion

# Get module strings
$script:resourceStrings = Get-ModuleResource
