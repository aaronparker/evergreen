function Get-EvergreenAppsPath {
    if (Test-Path -Path Env:EVERGREEN_APPS_PATH) {
        return ${Env:EVERGREEN_APPS_PATH}
    }
    else {
        $AppsPath = if ($IsWindows) {
            Join-Path -Path ${Env:LOCALAPPDATA} -ChildPath 'Evergreen'
        }
        else {
            Join-Path -Path $HOME -ChildPath '.evergreen'
        }
        return $AppsPath
    }
}
