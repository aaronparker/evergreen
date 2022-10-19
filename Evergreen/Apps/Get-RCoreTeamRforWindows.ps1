Function Get-RCoreTeamRforWindows {
    <#
        .SYNOPSIS
            Get the current version and download URL for R for Windows.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
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

    # Read the RCoreTeamRforWindows version from the YML source
    $params = @{
        Uri = $res.Get.Update.Uri
        Raw = $true
    }
    $Content = Invoke-WebRequestWrapper @params

    if ($Null -ne $Content) {
        try {
            $Version = [RegEx]::Match($Content, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            $Version = "Latest"
        }

        # Follow the download link
        try {
            $Content = Invoke-WebRequestWrapper $res.Get.Download.Uri
            $File = [RegEx]::Match($Content, $res.Get.Download.MatchFile).Captures.Groups[1].Value
            $Url = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $File
        }
        catch {
            $Url = $res.Get.Download.Uri
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = $Url
        }
        Write-Output -InputObject $PSObject
    }
}
