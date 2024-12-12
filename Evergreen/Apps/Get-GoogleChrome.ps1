function Get-GoogleChrome {
    <#
        .SYNOPSIS
            Returns the available Google Chrome versions across all platforms and channels by querying the official Google version JSON.

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

    foreach ($Channel in $res.Get.Update.Channels) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Channel: $Channel."

        # Get the list of versions for the channel
        $params = @{
            Uri       = $($res.Get.Update.Uri -replace "#channel", $Channel)
            UserAgent = $res.Get.Update.UserAgent
        }
        $Versions = Invoke-EvergreenRestMethod @params

        # Sort versions for the latest version
        $Version = $Versions | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.version }; Descending = $true } | `
            Select-Object -First 1 | `
            Select-Object -ExpandProperty "version"
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version"

        # Get date for this version
        $params = @{
            Uri       = $($res.Get.Update.DateUri -replace "#channel", $Channel).ToLower()
            UserAgent = $res.Get.Update.UserAgent
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand): Get release data for this channel."
        $Dates = Invoke-EvergreenRestMethod @params
        $LatestDate = $Dates.releases | Where-Object { $_.version -eq $Version }

        # Get the short date
        Write-Verbose -Message "$($MyInvocation.MyCommand): Get short date from $($LatestDate.serving.startTime)."
        if ($LatestDate.serving.startTime -is [System.DateTime]) {
            $Date = $LatestDate.serving.startTime[0].ToShortDateString()
        }
        else {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Convert string to DateTime."
            $Date = ([System.DateTime]$LatestDate.serving.startTime[0]).ToShortDateString()
        }

        # Output the version and URI object
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Channel      = $Channel
            StartDate    = $Date
            Architecture = Get-Architecture -String $res.Get.Download.Uri.$Channel
            Type         = Get-FileType -File $res.Get.Download.Uri.$Channel
            URI          = $res.Get.Download.Uri.$Channel
        }
        Write-Output -InputObject $PSObject

        if ($Channel -eq $res.Get.Download.BundleFilter) {
            # Output the version and URI for the bundle download
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Channel      = $Channel
                StartDate    = $Date
                Architecture = Get-Architecture -String $res.Get.Download.Bundle
                Type         = Get-FileType -File $res.Get.Download.Bundle
                URI          = $res.Get.Download.Bundle
            }
            Write-Output -InputObject $PSObject
        }

        if ($Channel -match $res.Get.Download.'32bitFilter') {
            # Output the version and URI object for the 32-bit version
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Channel      = $Channel
                StartDate    = $Date
                Architecture = Get-Architecture -String $($res.Get.Download.Uri.$Channel -replace "64", "")
                Type         = Get-FileType -File $res.Get.Download.Uri.$Channel
                URI          = $res.Get.Download.Uri.$Channel -replace "64", ""
            }
            Write-Output -InputObject $PSObject
        }

        if ($Channel -match $res.Get.Download.'ArmFilter') {
            # Output the version and URI object for the ARM version
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Channel      = $Channel
                StartDate    = $Date
                Architecture = Get-Architecture -String $($res.Get.Download.Uri.$Channel -replace "64", "_Arm64")
                Type         = Get-FileType -File $res.Get.Download.Uri.$Channel
                URI          = $res.Get.Download.Uri.$Channel -replace "64", "_Arm64"
            }
            Write-Output -InputObject $PSObject
        }
    }
}
