Function Get-CitrixWorkspaceApp {
    <#
        .SYNOPSIS
            Returns the current Citrix Workspace app, Receiver and HDX RTME releases.

        .DESCRIPTION
            Returns the current Citrix Workspace app, Receiver and HDX RTME releases.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://stealthpuppy.com/latest-receiver-version-powershell/

        .EXAMPLE
            Get-CitrixWorkspaceApp

            Description:
            Returns the available Citrix Workspace app, Receiver and HDX RTME releases for all platforms.
    #>
    [CmdletBinding()]
    Param()

    #region Read the Citrix Workspace app for Windows updater feed
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.CitrixWorkspaceApp.UriWindows

    # Convert content to XML document
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

        # Build an output object by selecting installer entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {
            ForEach ($installer in (Select-Xml -Xml $xmlDocument -XPath "//Installer")) {
                $PSObject = [PSCustomObject] @{
                    Version  = $installer.Node.Version
                    Title    = $($installer.Node.ShortDescription -replace ":", "")
                    Size     = $installer.Node.Size
                    Hash     = $installer.Node.Hash
                    Date     = $installer.Node.StartDate
                    Platform = "Windows"
                    URI      = "$($script:resourceStrings.Applications.CitrixWorkspaceApp.DownloadUri)$($installer.Node.DownloadURL)"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Citrix Workspace update feed."
    }
    #endregion

    #region Read the Citrix Workspace app updater feed
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.CitrixWorkspaceApp.UriMacOS

    # Convert content to XML document
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

        # Build an output object by selecting installer entries from the feed
        If ($xmlDocument -is [System.XML.XMLDocument]) {
            ForEach ($installer in (Select-Xml -Xml $xmlDocument -XPath "//Installer")) {
                $PSObject = [PSCustomObject] @{
                    Version  = $installer.Node.Version
                    Title    = $($installer.Node.ShortDescription -replace ":", "")
                    Size     = $(If ($installer.Node.Size) { $installer.Node.Size } Else { "Unknown" })
                    Hash     = $installer.Node.Hash
                    Date     = $installer.Node.StartDate
                    Platform = "macOS"
                    URI      = "$($script:resourceStrings.Applications.CitrixWorkspaceApp.DownloadUri)$($installer.Node.DownloadURL)"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to read Citrix Workspace update feed."
    }
    #endregion
}
