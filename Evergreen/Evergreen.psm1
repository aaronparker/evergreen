<#
    .SYNOPSIS
        Evergreen script to initiate the module
#>
[CmdletBinding()]
Param()

#region Get public and private function definition files
$publicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$privateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$public = @( Get-ChildItem -Path (Join-Path $publicRoot "*.ps1") -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path (Join-Path $privateRoot "*.ps1") -ErrorAction SilentlyContinue )

# Dot source the files
ForEach ($import in @($Public + $Private)) {
    Try {
        . $import.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

# Export the public modules and aliases
Export-ModuleMember -Function $public.Basename -Alias *
#endregion

# Get module strings
$script:resourceStrings = Get-ModuleResource
