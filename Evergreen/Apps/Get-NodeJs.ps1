Function Get-NodeJs {
    <#
        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name ends in s")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get latest version and download latest release via update API
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $UpdateFeed = Invoke-RestMethodWrapper @params

    if ($null -ne $updateFeed) {

        # Output the Current version
        $CurrentVersion = $UpdateFeed | Where-Object { $_.lts -eq $false } | Select-Object -First 1
        foreach ($Url in $res.Get.Download.Uri.Current) {
            $PSObject = [PSCustomObject] @{
                Version      = $CurrentVersion.version.TrimStart($res.Get.Update.TrimStart)
                Architecture = Get-Architecture -String $Url
                Type         = Get-FileType -File $Url
                Channel      = "Current"
                URI          = $Url -replace $res.Get.Download.ReplaceText, $CurrentVersion.version
            }
            Write-Output -InputObject $PSObject
        }

        # Output the LTS version
        $LtsVersion = $UpdateFeed | Where-Object { $_.lts -ne $false } | Select-Object -First 1
        foreach ($Url in $res.Get.Download.Uri.LTS) {
            $PSObject = [PSCustomObject] @{
                Version      = $LtsVersion.version.TrimStart($res.Get.Update.TrimStart)
                Architecture = Get-Architecture -String $Url
                Type         = Get-FileType -File $Url
                Channel      = "LTS"
                URI          = $Url -replace $res.Get.Download.ReplaceText, $LtsVersion.version
            }
            Write-Output -InputObject $PSObject
        }
    }
}
