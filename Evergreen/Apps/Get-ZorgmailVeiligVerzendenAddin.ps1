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

    # Query the Horizon Client update feed
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $UpdateFeed = Invoke-RestMethodWrapper @params

    # Convert content to XML document
    If ($Null -ne $UpdateFeed) {

        $res.Get.Download.Editions | Foreach {

            $uri = $res.Get.Download.Uri
                        
            If ($_ -eq "Default"){
                $uri = $uri -replace "#edition", ""
            }Else{
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
