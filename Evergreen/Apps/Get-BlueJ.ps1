Function Get-BlueJ {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of BlueJ.

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

    # Query the BlueJ update API
    $iwcParams = @{
        Uri       = $res.Get.Uri
        UserAgent = $res.Get.UserAgent
    }

    $Content = Invoke-WebRequestWrapper @iwcParams

    If ($Null -ne $Content) {

        # Convert from UTF8
        $Updates = [System.Text.Encoding]::UTF8.GetString($Content)

        # Latest version is stored at the top of the file on its own line
        $LatestVersion = $Updates.Split([Environment]::NewLine)[0]

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $LatestVersion
            URI     = $res.Get.DownloadUri -replace $res.Get.ReplaceText, ($LatestVersion.Replace(".", ""))
        }
        Write-Output -InputObject $PSObject
    }
}
