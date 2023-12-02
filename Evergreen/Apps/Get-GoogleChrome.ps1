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
        $Versions = Invoke-EvergreenRestMethod -Uri $($res.Get.Update.Uri -replace "#channel", $Channel)
        $Version = $Versions.releases.version | `
            Sort-Object -Property @{ Expression = { [System.Version]$_ }; Descending = $true } | `
            Select-Object -First 1
        Write-Verbose -Message "$($MyInvocation.MyCommand): Version: $Version"

        # Output the version and URI object
        $PSObject = [PSCustomObject] @{
            Version      = $Version
            Architecture = Get-Architecture -String $res.Get.Download.Uri.$Channel
            Channel      = $Channel
            Type         = Get-FileType -File $res.Get.Download.Uri.$Channel
            URI          = $res.Get.Download.Uri.$Channel
        }
        Write-Output -InputObject $PSObject

        if ($Channel -eq $res.Get.Download.BundleFilter) {
            # Output the version and URI for the bundle download
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = Get-Architecture -String $res.Get.Download.Bundle
                Channel      = $Channel
                Type         = Get-FileType -File $res.Get.Download.Bundle
                URI          = $res.Get.Download.Bundle
            }
            Write-Output -InputObject $PSObject
        }

        if ($Channel -match $res.Get.Download.'32bitFilter') {
            # Output the version and URI object for the 32-bit version
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = Get-Architecture -String $($res.Get.Download.Uri.$Channel -replace "64", "")
                Channel      = $Channel
                Type         = Get-FileType -File $res.Get.Download.Uri.$Channel
                URI          = $res.Get.Download.Uri.$Channel -replace "64", ""
            }
            Write-Output -InputObject $PSObject
        }
    }
}
