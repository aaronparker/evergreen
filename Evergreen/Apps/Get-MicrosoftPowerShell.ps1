Function Get-MicrosoftPowerShell {
    <#
        .SYNOPSIS
            Returns the latest PowerShell version number and download.

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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Get the latest release from the PowerShell metadata
    try {
        # Get details from the update feed
        $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    }
    catch {
        Throw "Failed to resolve metadata: $($res.Get.Update.Uri)."
        Break
    }

    # Query the releases API for each release tag specified in the manifest
    ForEach ($release in $res.Get.Download.Tags.GetEnumerator()) {

        # Determine the tag
        $Tag = $updateFeed.($res.Get.Download.Tags[$release.key])
        Write-Verbose -Message "$($MyInvocation.MyCommand): Query release for tag: $Tag."

        # Pass the repo releases API URL and return a formatted object
        $params = @{
            Uri          = "$($res.Get.Download.Uri)$($Tag)"
            MatchVersion = $res.Get.Download.MatchVersion
            Filter       = $res.Get.Download.MatchFileTypes
        }
        $object = Get-GitHubRepoRelease @params

        # Add the Release property to the object returned from Get-GitHubRepoRelease
        $object | Add-Member -MemberType "NoteProperty" -Name "Release" -value $release.Name
        Write-Output -InputObject $object
    }
}
