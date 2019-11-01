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

    Try {
        [System.XML.XMLDocument] $xmlDocument = $Content
    }
    Catch [System.IO.IOException] {
        Write-Warning -Message "Failed to read XML. Check update URL: $($script:resourceStrings.Applications.NotepadPlusPlus.Uri)."
        Throw $_.Exception.Message
    }
    Catch [System.Exception] {
        Write-Warning -Message "Failed to read XML."
        Throw $_
    }
    
    # Select each target XPath to return version and download details
    If ($xmlDocument -is [System.XML.XMLDocument]) {
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
        Write-Warning -Message "$($MyInvocation.MyCommand): Check update URL: $($script:resourceStrings.Applications.NotepadPlusPlus.Uri)."
        $PSObject = [PSCustomObject] @{
            Version      = "Unknown"
            URI          = "Unknown"
        }
        Write-Output -InputObject $PSObject
    }
}
