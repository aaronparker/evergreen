Function Get-CitrixReceiver {
    <#
        .SYNOPSIS
            Gets the current available Citrix Receiver release versions.

        .DESCRIPTION
            Reads the public Citrix Receiver web page to return an array of Receiver platforms and the available versions.
            Does not provide the version number for Receiver where a login is required (e.g. HTML5, Chrome)

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://stealthpuppy.com/latest-receiver-version-powershell/

        .EXAMPLE
            Get-CitrixReceiver

            Description:
            Returns the available Citrix Receiver versions for all platforms.

        .EXAMPLE
            Get-CitrixReceiverVersion -Platform Windows | Select-Object -First 1

            Description:
            Returns the latest available Citrix Receiver version available for Windows.
    #>
    [CmdletBinding()]
    Param()
    # RegEx to filter out all characters except the version number
    $RegExNumbers = "[^.0-9]"
    $RegExVersion = "\d+(\.\d+)+\s"

    # Read the Citrix Receiver RSS feed
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.CitrixReceiver.Uri

    # Convert to XML document
    If ($Null -ne $Content) {
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.IO.IOException] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to read."
            Throw $_.Exception.Message
        }
        Catch [System.Exception] {
            Throw $_
        }

        If ($xmlDocument -is [System.XML.XMLDocument]) {
            ForEach ($item in (Select-Xml -Xml $xmlDocument -XPath "//item")) {
                If ((($item.Node.Title -replace $script:resourceStrings.Applications.CitrixReceiver.TitleReplace, "") `
                            -match "^Receiver*") -and $item.Node.Title -notmatch "SDK") {
                    $PSObject = [PSCustomObject] @{
                        Version = $item.Node.Title -replace $script:resourceStrings.Applications.CitrixReceiver.RegExNumbers
                        Title   = $(($item.Node.Title -replace $script:resourceStrings.Applications.CitrixReceiver.TitleReplace, "") `
                                -replace $script:resourceStrings.Applications.CitrixReceiver.RegExVersion)
                        URI     = $item.Node.Link
                    }
                    Write-Output -InputObject $PSObject
                }
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Citrix Receiver RSS feed."
    }
}
