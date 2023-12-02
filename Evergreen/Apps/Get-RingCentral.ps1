Function Get-RingCentral {
    <#
        .SYNOPSIS
            Get the current version and download URL for RingCentral.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the RingCentral version from the YML source
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-EvergreenRestMethod @params
    try {
        $YmlVersion = [RegEx]::Match($Content, $res.Get.MatchYmlVersion).Captures.Groups[1].Value
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $YmlVersion."
        Write-Warning -Message "$($MyInvocation.MyCommand): Reporting version from the RingCentral desktop app: $YmlVersion."
        Write-Warning -Message "$($MyInvocation.MyCommand): See this article for more detail: https://support.ringcentral.com/download.html"
    }
    catch {
        $YmlVersion = "Latest"
    }

    ForEach ($platform in $res.Get.Download.Keys) {
        ForEach ($installer in $res.Get.Download[$platform].Keys) {

            # Follow the download link which will return a 301/302
            $redirectUrl = Resolve-SystemNetWebRequest -Uri $res.Get.Download[$platform][$installer]

            # Match the URL without the text after the ?
            try {
                $Url = [RegEx]::Match($redirectUrl.ResponseUri.AbsoluteUri, $res.Get.MatchUrl).Captures.Groups[1].Value
            }
            catch {
                $Url = $redirectUrl.ResponseUri.AbsoluteUri
            }

            # Match version number from the download URL
            try {
                $Version = [RegEx]::Match($Url, $res.Get.MatchFileVersion).Captures.Groups[0].Value
            }
            catch {
                $Version = $YmlVersion
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
