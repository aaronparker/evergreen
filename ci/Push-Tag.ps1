<#
    .SYNOPSIS
        Set a tag and push
#>
[CmdletBinding()]
param()

$Path = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
$Module = Test-ModuleManifest -Path "$Path/Evergreen/Evergreen.psm1"
if ($null -ne $Module) {
    git tag "v$($Module.Version.ToString())"
    git push origin --tags
}
