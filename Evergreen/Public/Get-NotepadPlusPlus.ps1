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
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the Notepad++ version and download XML
    $iwcParams = @{
        Uri = $res.Get.Uri
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
        If ($Failed -ne 1) {

            # Select the required node/s from the XML feed
            $nodes = Select-Xml -Xml $xmlDocument -XPath $res.Get.XmlNode | Select-Object –ExpandProperty "node"

            # Construct the output; Return the custom object to the pipeline
            ForEach ($node in $nodes) {
                $PSObject = [PSCustomObject] @{
                    Version      = $node.Version
                    Architecture = "x86"
                    URI          = $node.Location
                }
                Write-Output -InputObject $PSObject

                # Fix the -replace with RegEx later
                $PSObject = [PSCustomObject] @{
                    Version      = $node.Version
                    Architecture = "x64"
                    URI          = $($node.Location -replace "Installer.exe", "Installer.x64.exe")
                }
                Write-Output -InputObject $PSObject
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to read update URL: $($res.Get.Uri)."
            $PSObject = [PSCustomObject] @{
                Error = "Check update URL"
            }
            Write-Output -InputObject $PSObject
        }
    }
}
