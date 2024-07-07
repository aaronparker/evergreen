function Get-FileZilla {
    <#
        .SYNOPSIS
            Get the current version and download URI for FileZilla for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the update feed
    $params = @{
        Uri                  = $res.Get.Update.Uri
        UserAgent            = $res.Get.Update.UserAgent
        Headers              = @{
            Accept = "*/*"
        }
        SkipCertificateCheck = $true
        Raw                  = $true
    }
    $Content = Invoke-EvergreenWebRequest @params

    # Convert the content to an object
    $Updates = $Content | ConvertFrom-Csv -Delimiter $res.Get.Update.Delimiter -Header $res.Get.Update.Headers | `
        Where-Object { $_.Channel -eq $res.Get.Update.Channel }

    # Output the object to the pipeline
    foreach ($Update in $Updates) {
        $PSObject = [PSCustomObject] @{
            Version = $Update.Version
            Size    = $Update.Size
            Hash    = $Update.Hash
            URI     = "$($res.Get.Download.Uri)$(Split-Path -Path $Update.URI -Leaf)"
        }
        Write-Output -InputObject $PSObject
    }
}
