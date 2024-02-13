Function Get-AdobeDigitalEditions {
    <#
        .SYNOPSIS
            Gets the version and download URLs for Adobe Digital Editions.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
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
    }
    $updateFeed = Invoke-EvergreenRestMethod @params

    # Removing first 3 bytes from array by selecting the full length and stripping first 3
    Write-Verbose "Remove-ByteOrderMark (UTF8 BOM)"
    $OutputBytes = $updateFeed[3..$updateFeed.Length]
    $updateFeed = [System.Text.Encoding]::UTF8.GetString($OutputBytes) | ConvertFrom-Json

    if ($Null -ne $updateFeed) {

        # Output the object to the pipeline
        foreach ($item in $updateFeed) {
            $PSObject = [PSCustomObject] @{
                Version = $item.version
                URI     = $item.SecuredDownloadPath
            }
            Write-Output -InputObject $PSObject
        }

    }
    else {
        Write-Error -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
}