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

    # Query the Beyond Compare update API
    $params = @{
        Uri       = $res.Get.Update.Uri
        UserAgent = $res.Get.Update.UserAgent
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

            # Replace text in the version string
            $Version = $Update.latestVersion -replace $res.Get.Update.ReplaceText, "."
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version"
            if ($Version -notmatch $res.Get.Update.MatchVersion) {
                $Version = [RegEx]::Match($Update.latestVersion, $res.Get.Update.MatchVersion).Captures.Value
                $Version = "$($Version).$($Update.latestBuild)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version"
            }

            # Step through each language
            foreach ($language in $res.Get.Update.Languages.GetEnumerator()) {

                # Output the version and download URL
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Language     = $res.Get.Update.Languages[$language.key]
                    Architecture = Get-Architecture -String $Update.download
                    Type         = Get-FileType -File $Update.download
                    URI          = if ($language.key -eq "en") { $Update.download } else { $Update.download -replace "BCompare-", "BCompare-$($language.key)-" }
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
