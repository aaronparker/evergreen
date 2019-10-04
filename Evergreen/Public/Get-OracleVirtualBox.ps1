Function Get-OracleVirtualBox {
    <#
        .SYNOPSIS
            Get the current version and download URL for the XenServer tools.

        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-OracleVirtualBox

            Description:
            Returns the latest verison and downloads for each operating system.
    #>
    [CmdletBinding()]
    Param()    
    
    # Get latest VirtualBox version
    $Version = Invoke-WebContent -Uri $script:resourceStrings.Applications.OracleVirtualBox.Uri
    $Version -match $script:resourceStrings.Applications.OracleVirtualBox.MatchVersion | Out-Null
    $Version = $Matches[0]
    Write-Verbose "$($script:resourceStrings.Applications.OracleVirtualBox.DownloadUri)$Version/"
    
    # Get the content from the latest downloads folder
    $iwrParams = @{
        Uri             = "$($script:resourceStrings.Applications.OracleVirtualBox.DownloadUri)$Version/"
        UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
        UseBasicParsing = $True
        ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
    }
    $Downloads = Invoke-WebRequest @iwrParams

    # Filter downloads with the version string and the file types we want
    $RegExVersion = $Version -replace ("\.", "\.")
    $MatchFileTypes = $script:resourceStrings.Applications.OracleVirtualBox.MatchFileTypes -replace "Version", $RegExVersion
    $Links = $Downloads.Links.outerHTML | Select-String -Pattern $MatchFileTypes

    # Construct an array with the version number and each download
    ForEach ($link in $Links) {
        $link -match $script:resourceStrings.Applications.OracleVirtualBox.MatchDownloadFile | Out-Null
        $PSObject = [PSCustomObject] @{
            Version  = $Version
            Platform = "Platform"
            URI      = "$($script:resourceStrings.Applications.OracleVirtualBox.DownloadUri)$Version/$($Matches[1])"
        }
        Switch ($PSObject.URI.Substring($PSObject.URI.Length - 3)) {
            "exe" {
                $PSObject.Platform = "Windows"
            }
            "dmg" {
                $PSObject.Platform = "macOS"
            }
            "deb" {
                $PSObject.Platform = "Debian"
            }
            "rpm" {
                $PSObject.Platform = "RedHat"
            }
            Default {
                $PSObject.Platform = "Unknown"
            }
        }
        Write-Output -InputObject $PSObject
    }
}
