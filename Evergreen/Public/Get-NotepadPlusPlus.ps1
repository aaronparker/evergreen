Function Get-NotepadPlusPlus {
    <#
        .SYNOPSIS
            Returns the latest Notepad++ version and download URI.

        .DESCRIPTION
            Returns the latest Notepad++ version and download URI.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-NotepadPlusPlus

            Description:
            Returns the latest x86 and x64 Notepad++ version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param ()

    # Read the Notepad++ version and download XML
    $iwcParams = @{
        Uri = $script:resourceStrings.Applications.NotepadPlusPlus.Uri
    }
    $Content = Invoke-WebContent @iwcParams

    $Failed = 0
    Try {
        [System.XML.XMLDocument] $xmlDocument = $Content
    }
    Catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to convert XML."
        $Failed = 1
    }
    Finally {
        # Select each target XPath to return version and download details
        #If (($Null -ne $xmlDocument) -or ($xmlDocument -is [System.XML.XMLDocument])) {
        If ($Failed -ne 1) {
            $PSObject = [PSCustomObject] @{
                Version      = $xmlDocument.GUP.Version
                Architecture = "x86"
                URI          = $xmlDocument.GUP.Location
            }
            Write-Output -InputObject $PSObject

            # Fix the -replace with RegEx later
            $PSObject = [PSCustomObject] @{
                Version      = $xmlDocument.GUP.Version
                Architecture = "x64"
                URI          = $($xmlDocument.GUP.Location -replace "Installer.exe", "Installer.x64.exe")
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to read update URL: $($script:resourceStrings.Applications.NotepadPlusPlus.Uri)."
            $PSObject = [PSCustomObject] @{
                Error = "Check update URL"
            }
            Write-Output -InputObject $PSObject
        }
    }
}
