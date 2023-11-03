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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the Postman update API
    ForEach ($item in $res.Get.Update.Uri.GetEnumerator()) {
        $params = @{
            Uri         = $res.Get.Update.Uri[$item.Key]
            ContentType = $res.Get.Update.ContentType
        }
        $Content = Invoke-EvergreenRestMethod @params
        If ($Null -ne $Content) {

            # Work out latest version
            $LatestVersion = $Content.changelog | `
                Sort-Object -Property @{ Expression = { [System.Version]$_.name }; Descending = $true } | `
                Select-Object -First 1

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $LatestVersion.name
                Size         = $LatestVersion.assets.size
                Hash         = $LatestVersion.assets.hash
                Date         = ConvertTo-DateTime -DateTime ($LatestVersion.createdAt) -Pattern $res.Get.Update.DatePattern
                Architecture = $item.Name
                Filename     = $LatestVersion.assets.name
                URI          = $LatestVersion.assets.url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
