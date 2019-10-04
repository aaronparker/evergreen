<#
    .SYNOPSIS
        AppVeyor build script.
#>
[OutputType()]
Param ()

If (Get-Variable -Name projectRoot -ErrorAction SilentlyContinue) {
    # Do something
}
Else {
    Write-Warning -Message "Required variable does not exist: $projectRoot."
}
