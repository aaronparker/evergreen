Function Get-Gpg4win {
    <#
        .SYNOPSIS
            Returns the available gpg4win versions.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get files from server (https://files.gpg4win.org/)
    $Response = Invoke-WebRequest -Uri $res.Get.Update.Uri -UseBasicParsing

    if ($Null -ne $Response) {
        # Filter and sort by latest (gpg4win-4.0.3.exe)
        $LatestVersion = ($Response.Links | Where-Object { $_.href -match $res.Get.Update.MatchFile } | Sort-Object -Property href -Descending | Select-Object -First 1).href

        $Version = [RegEx]::Match($LatestVersion, $res.Get.Update.MatchVersion).Value

        # Create download uri https://files.gpg4win.org/#version -> https://files.gpg4win.org/gpg4win-4.0.3.exe
        $Uri = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $LatestVersion

        # Output the Version and URI object
        [PSCustomObject] @{
            Version      = $Version
            Architecture = $res.Get.Download.Architecture
            Type         = [System.IO.Path]::GetExtension($Uri).TrimStart(".")
            URI          = $Uri
        }
    }
}
