Function Get-NotepadPpUri {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [ValidateSet('x86','x64')]
        [string] $Architecture = "x64"
    )

    $version = Get-NotepadPpVersion
    If ("x86" -eq $Architecture) { $archcode = "" } Else { $archcode = ".x64" }
    
    $url = "https://notepad-plus-plus.org/repository/$($version.major).x/$version/npp.$($version).Installer$($archcode).exe"
    Write-Output $url
}
