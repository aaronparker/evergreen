function Get-ScooterBeyondCompare {
    <#
        .SYNOPSIS
            Returns the latest Beyond Compare and download URL.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($language in $res.Get.Uri.GetEnumerator()) {

        # Query the Beyond Compare update API
        $params = @{
            Uri       = $res.Get.Uri[$language.key]
            UserAgent = $res.Get.UserAgent
        }
        $Content = Invoke-EvergreenRestMethod @params
        if ($null -ne $Content) {

            if ($Content -is [System.Xml.XmlDocument]) {
                $XmlContent = $Content
            }
            else {
                # Normalize the XML content
                $Content = $Content -replace "<a", "" -replace "</a>", ""
                $XmlContent = New-Object -TypeName "System.Xml.XmlDocument"
                $XmlContent.LoadXml($Content)
            }

            # Build an array of the latest release and download URLs
            foreach ($Update in $XmlContent.Update) {
                try {
                    $Version = [RegEx]::Match($Update.latestVersion, $res.Get.MatchVersion).Captures.Value
                    $Version = "$($Version).$($Update.latestBuild)"
                }
                catch {
                    $Version = $Update.latestVersion
                }

                $PSObject = [PSCustomObject] @{
                    Version  = $Version
                    Language = $res.Get.Languages[$language.key]
                    Type     = Get-FileType -File $Update.download
                    URI      = $Update.download
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
