function Get-EvergreenAppsPath {
    $AppsPath = if ($IsWindows) { Join-Path -Path ${Env:LOCALAPPDATA} -ChildPath 'Evergreen' } else { Join-Path -Path $HOME -ChildPath '.evergreen' }
    return $AppsPath
}
