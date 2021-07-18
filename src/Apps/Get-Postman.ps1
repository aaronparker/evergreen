Function Get-Postman {
    <#
        .SYNOPSIS
            Get the current version and download URIs for Postman.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
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

    # Query the Postman update API
    $params = @{
        Uri         = $res.Get.Uri
        ContentType = "application/octet-stream"
    }

    $Content = Invoke-RestMethodWrapper @params

    If ($Null -ne $Content) {

        # Work out latest version
        $LatestVersion = $Content.changelog | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.name }; Descending = $true } | `
            Select-Object -First 1

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version  = $LatestVersion.name
            Size     = $LatestVersion.assets.size
            Hash     = $LatestVersion.assets.hash
            Date     = ConvertTo-DateTime -DateTime ($LatestVersion.createdAt) -Pattern $res.Get.DatePattern 
            Filename = $LatestVersion.assets.name
            URI      = $LatestVersion.assets.url
        }
        Write-Output -InputObject $PSObject
        
    }
}
