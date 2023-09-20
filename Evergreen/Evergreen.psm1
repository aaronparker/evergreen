<#
    .SYNOPSIS
        Evergreen script to initiate the module
#>
[CmdletBinding(SupportsShouldProcess = $False)]
param ()

#region Get public and private function definition files
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

# Export the public modules and aliases
Export-ModuleMember -Function $public.Basename -Alias *
#endregion

# Get module strings
$script:resourceStrings = Get-ModuleResource
