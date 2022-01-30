Function Get-TelerikFiddlerClassic {
    <#
        .SYNOPSIS
            Get the current version and download URL for Telerik Fiddler Classic.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    $Response = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri

    # Construct the output; Return the custom object to the pipeline
    If ($Null -ne $Response) {

        # Construct the version number
        $Lines = $Response.Split("`r`n")
        $Version =  "$($Lines[0]).$($Lines[1]).$($Lines[2]).$($Lines[3])"

        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = $res.Get.Download.Uri
        }
        Write-Output -InputObject $PSObject
    }
}
