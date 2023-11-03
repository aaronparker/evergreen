Function Get-BitwardenDesktop {
    <#
        .SYNOPSIS
            Returns the latest Bitwarden Desktop version number and download.
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

    # Read the BitwardenDesktop version from the text source
    $params = @{
        Uri = $res.Get.Update.Uri
        UserAgent = "electron-builder"
        ReturnObject = "RawContent"
    }
    $Content = Invoke-EvergreenWebRequest @params

    If ($Null -ne $Content) {
        try {
            $Version = [RegEx]::Match($Content, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version, from update source: $($res.Get.Update.Uri)."
        }
        catch {
            $Version = "Latest"
            Write-Warning -Message "$($MyInvocation.MyCommand): Unable to determine version."
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Type         = [System.IO.Path]::GetExtension($res.Get.Download.Uri).Split(".")[-1]
            URI          = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $Version
        }
        Write-Output -InputObject $PSObject
    }
}
