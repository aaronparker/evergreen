Function Get-MicrosoftTeams {
    <#
        .SYNOPSIS
            Returns the available Microsoft Teams versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

            https://teams.microsoft.com/desktopclient/installer/windows/x64
            https://teams.microsoft.com/desktopclient/installer/windows/x86
            https://teams.microsoft.com/desktopclient/installer/windows/arm64
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Step through each release ring
    ForEach ($ring in $res.Get.Update.Rings.GetEnumerator()) {

        # Read the JSON and convert to a PowerShell object. Return the release version of Teams
        Write-Verbose -Message "$($MyInvocation.MyCommand): Query ring: $($ring.Name): $($res.Get.Update.Rings[$ring.Key])."
        $params = @{
            Uri       = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $res.Get.Update.Rings[$ring.Key]
            UserAgent = $res.Get.Update.UserAgent
        }
        $updateFeed = Invoke-RestMethodWrapper @params

        # Read the JSON and build an array of platform, channel, version
        If ($Null -ne $updateFeed) {

            # Match version number
            $Version = [RegEx]::Match($updateFeed.releasesPath, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

            # Step through each architecture
            ForEach ($Architecture in $res.Get.Download.Architecture) {

                # Query for the installer
                $params = @{
                    Uri       = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText.architecture, $Architecture -replace $res.Get.Download.ReplaceText.ring, $res.Get.Update.Rings[$ring.Key]
                    UserAgent = $res.Get.Update.UserAgent
                }
                $Uri = Invoke-RestMethodWrapper @params
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found installer: $Uri."

                # Build the output object and output object to the pipeline
                If ($Null -ne $Uri) {

                    ForEach ($extension in $res.Get.Download.Extensions) {
                        $Uri = $Uri -replace ".exe$", $extension
                        $PSObject = [PSCustomObject] @{
                            Version      = $Version
                            Ring         = $ring.Name
                            Architecture = Get-Architecture -String $Uri
                            Type         = [System.IO.Path]::GetExtension($Uri).Split(".")[-1]
                            URI          = $Uri
                        }
                        Write-Output -InputObject $PSObject
                    }
                }
            }
        }
    }
}
