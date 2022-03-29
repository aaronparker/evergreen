Function Get-FileZilla {
    <#
        .SYNOPSIS
            Get the current version and download URI for FileZilla for Windows.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the update feed
    $params = @{
        Uri                  = $res.Get.Update.Uri
        UserAgent            = $res.Get.Update.UserAgent
        SkipCertificateCheck = $True
        Raw                  = $True
    }
    $Content = Invoke-WebRequestWrapper @params

    # Convert the content to an object
    try {
        $Updates = ($Content | ConvertFrom-Csv -Delimiter $res.Get.Update.Delimiter -Header $res.Get.Update.Headers) | `
            Where-Object { $_.Channel -eq $res.Get.Update.Channel }
    }
    catch [System.Exception] {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert update feed."
        Break
    }

    # Output the object to the pipeline
    ForEach ($Update in $Updates) {
        $PSObject = [PSCustomObject] @{
            Version = $Update.Version
            Size    = $Update.Size
            Hash    = $Update.Hash
            URI     = "$($res.Get.Download.Uri)$(Split-Path -Path $Update.URI -Leaf)"
        }
        Write-Output -InputObject $PSObject
    }
}
