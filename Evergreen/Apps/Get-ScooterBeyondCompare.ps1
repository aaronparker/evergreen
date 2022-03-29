Function Get-ScooterBeyondCompare {
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
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

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
