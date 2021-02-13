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
            Returns the latest version and downloads for each operating system.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name
    
    # Get latest VirtualBox version
    $Version = Invoke-WebRequestWrapper -Uri $res.Get.Update.Uri

    If ($Null -ne $Version) {
        $Version = [RegEx]::Match($Version, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
        Write-Verbose "$($res.Get.Download.Uri)$Version/"
    
        # Get the content from the latest downloads folder
        $iwrParams = @{
            Uri             = "$($res.Get.Download.Uri)$Version/"
            UserAgent       = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
            UseBasicParsing = $True
            ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
        }
        $Downloads = Invoke-WebRequest @iwrParams

        If ($Null -ne $Downloads) {
            # Filter downloads with the version string and the file types we want
            $RegExVersion = $Version -replace ("\.", "\.")
            $MatchExtensions = $res.Get.Download.MatchExtensions -replace "Version", $RegExVersion
            $Links = $Downloads.Links.outerHTML | Select-String -Pattern $MatchExtensions

            # Construct an array with the version number and each download
            ForEach ($link in $Links) {
                $link -match $res.Get.Download.MatchDownloadFile | Out-Null
                $Uri = "$($res.Get.Download.Uri)$Version/$($Matches[1])"

                $PSObject = [PSCustomObject] @{
                    Version = $Version
                    Type    = [System.IO.Path]::GetExtension($Uri).Split(".")[-1]
                    URI     = $Uri
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
