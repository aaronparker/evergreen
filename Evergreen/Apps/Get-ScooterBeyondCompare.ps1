Function Get-ScooterBeyondCompare {
    <#
        .SYNOPSIS
            Returns the latest Beyond Compare and download URL.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ScooterBeyondCompare

            Description:
            Returns the latest Beyond Compare and download URL.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name    

    ForEach ($language in $res.Get.Uri.GetEnumerator()) {

        # Query the Beyond Compare update API
        $iwcParams = @{
            Uri       = $res.Get.Uri[$language.key]
            UserAgent = $res.Get.UserAgent
        }
        $Content = Invoke-RestMethodWrapper @iwcParams

        # If something is returned
        If ($Null -ne $Content) {

            # Build an array of the latest release and download URLs
            ForEach ($update in $Content.Update) {

                try {
                    $version = [RegEx]::Match($update.latestversion, $res.Get.MatchVersion).Captures.Value
                    $version = "$($version).$($update.latestBuild)"
                }
                catch {
                    $version = $update.latestVersion
                }

                $PSObject = [PSCustomObject] @{
                    Version  = $version
                    Language = $res.Get.Languages[$language.key]
                    URI      = $update.download
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
