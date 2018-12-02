Function Get-NotepadPpUri {
    <#
        .SYNOPSIS
            Returns the latest Notepad++ download URI.

        .DESCRIPTION
            Returns the latest Notepad++ download URI.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .PARAMETER Architecture
            Return 32-bit or 64-bit version of Notepad++

        .EXAMPLE
            Get-NotepadPpUri

            Description:
            Returns the latest 64-bit Notepad++ download URI.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [ValidateSet('x86','x64')]
        [string] $Architecture = "x64"
    )

    # Get the latest Notepad++ version number
    $version = Get-NotepadPpVersion

    If ("x86" -eq $Architecture) { $archcode = "" } Else { $archcode = ".x64" }
    $url = "https://notepad-plus-plus.org/repository/$($version.major).x/$version/npp.$($version).Installer$($archcode).exe"

    Write-Output $url
}
