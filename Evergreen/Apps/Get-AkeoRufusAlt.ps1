function Get-AkeoRufusAlt {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the update feed and convert the text into an array of lines
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    $UpdateFeedLines = $UpdateFeed -split "`n"

    # Match the version number
    $Version = (($UpdateFeedLines | Select-String -Pattern "^version" -CaseSensitive).Line -split "=")[-1].Trim()

    # For each architecture, match the download URL and return to the pipeline
    foreach ($Architecture in $res.Get.Update.Architectures.GetEnumerator()) {
        $Url = (($UpdateFeedLines | Select-String -Pattern $Architecture.Value).Line -split "=")[-1].Trim()
        [PSCustomObject] @{
            Version      = $Version
            Type         = Get-FileType -File $Url
            Architecture = $Architecture.Name
            URI          = $Url
        } | Write-Output
    }
}
