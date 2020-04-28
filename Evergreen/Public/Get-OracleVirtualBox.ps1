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
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name
    
    # Get latest VirtualBox version
    $Version = Invoke-WebContent -Uri $res.Get.Uri

    If ($Null -ne $Version) {
        $Version -match $res.Get.MatchVersion | Out-Null
        $Version = $Matches[0]
        Write-Verbose "$($res.Get.DownloadUri)$Version/"
    
        # Get the content from the latest downloads folder
        $iwrParams = @{
            Uri             = "$($res.Get.DownloadUri)$Version/"
            UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
            UseBasicParsing = $True
            ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
        }
        $Downloads = Invoke-WebRequest @iwrParams

        If ($Null -ne $Downloads) {
            # Filter downloads with the version string and the file types we want
            $RegExVersion = $Version -replace ("\.", "\.")
            $MatchExtensions = $res.Get.MatchExtensions -replace "Version", $RegExVersion
            $Links = $Downloads.Links.outerHTML | Select-String -Pattern $MatchExtensions

            # Construct an array with the version number and each download
            ForEach ($link in $Links) {
                $link -match $res.Get.MatchDownloadFile | Out-Null
                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    URI      = "$($res.Get.DownloadUri)$Version/$($Matches[1])"
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
