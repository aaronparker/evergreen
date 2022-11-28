Import-Module ./Evergreen/Evergreen.psd1 -Verbose -Force

foreach ($file in (Get-ChildItem -Path "./Evergreen/Private/*.ps1")) {
    . $file.FullName
}
