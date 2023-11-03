Function Get-ZorgmailVeiligVerzendenAddin {
    <#
        .NOTES
            Author: Rico Roodenburg
    #>

    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $UpdateFeed = Invoke-EvergreenRestMethod @params

    if ($Null -ne $UpdateFeed) {
        $res.Get.Download.Editions | ForEach-Object {
            $uri = $res.Get.Download.Uri
            if ($_ -eq "Default") {
                $uri = $uri -replace "#edition", ""
            }
            else {
                $uri = $uri -replace "#edition", "-$($_)"
            }

            $PSObject = [PSCustomObject] @{
                Version = $UpdateFeed.Version
                Edition = $_
                URI     = $uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
