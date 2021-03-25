Function Get-Zoom {    
    <#
        .SYNOPSIS
            Get the current version and download URL for Zoom.

        .NOTES
            Author: Trond Eirik Haavarstein
            Twitter: @xenappblog
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Zoom

            Description:
            Returns the current version and download URL for Zoom.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    ForEach ($platform in $res.Get.Download.Keys) {
        ForEach ($installer in $res.Get.Download[$platform].Keys) {

            # Follow the download link which will return a 301/302
            $redirectUrl = (Resolve-SystemNetWebRequest -Uri $res.Get.Download[$platform][$installer]).ResponseUri.AbsoluteUri

            # Match the URL without the text after the ?
            try {
                $Url = [RegEx]::Match($redirectUrl, $res.Get.MatchUrl).Captures.Groups[1].Value
            }
            catch {
                $Url = $redirectUrl
            }

            # Match version number from the download URL
            try {
                $Version = [RegEx]::Match($Url, $res.Get.MatchVersion).Captures.Groups[0].Value
            }
            catch {
                $Version = "Latest"
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version  = $Version
                Platform = $platform
                Type     = $installer
                URI      = $Url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
