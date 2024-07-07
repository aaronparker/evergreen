function Get-TelerikFiddlerClassic {
    <#
        .SYNOPSIS
            Get the current version and download URL for Telerik Fiddler Classic.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get the latest download
    $Response = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Construct the output; Return the custom object to the pipeline
    if ($null -ne $Response) {

        # Construct the version number
        $Lines = $Response.Split("`r`n")
        $Version =  "$($Lines[0]).$($Lines[1]).$($Lines[2]).$($Lines[3])"

        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = $res.Get.Download.Uri -replace "#version", $Version
        }
        Write-Output -InputObject $PSObject
    }
}
