function Get-ModuleVersion {
    try {
        $ErrorActionPreference = "Stop"
        $module = (Get-Module -Name $MyInvocation.MyCommand.ModuleName -All)[0]
        if ($null -ne $module) {
            return $module.Version
        }
        else {
            return $(Get-Date -Format "yyMM.2525")
        }
    }
    catch {
        return $(Get-Date -Format "yyMM.2525")
    }
}
