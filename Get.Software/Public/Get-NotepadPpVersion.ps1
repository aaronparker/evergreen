Function Get-NotepadPpVersion {
    <#
        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson

            Update: Aaron Parker
            Updated to use -UseBasicParsing and support PowerShell Core
    #>
    [CmdletBinding()]
    [OutputType([version])]
    Param()

    try {
        $url = "https://notepad-plus-plus.org/download/"
        $content = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to read Notepad++ URL with error $_."
    }
    finally {

        # Match a version number string in the <title> tag
        If ($content.Content -match "<title>(?<title>.*)</title>") {

            # Match for x.x.x and x.x version string used by Notepad++
            If ($Matches[0] -match "\d+\.\d+\.\d+") {
                $version = [Version]::new($Matches[0])
                Write-Output $version
            }
            ElseIf ($Matches[0] -match "\d+\.\d+") {
                $version = [Version]::new($Matches[0])
                Write-Output $version
            }
            Else {
                Throw "Unable to find Notepad++ version."
            }
        }
    }
}
