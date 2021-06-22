Function Get-Minitab {
    <#
        .SYNOPSIS
            Get the current version and download URI for the supported releases of Minitab.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    ForEach ($Release in $res.Get.Download.Releases) {

        # Build the update uri based on the release number
        $uri = $res.Get.Update.Uri -replace $res.Get.Update.ReplaceRelease, $Release

        # Query the update feed
        $params = @{
            Uri             = $uri
            UseBasicParsing = $True
        }
        $Updatefeed = (Invoke-WebRequest @params).Content

        # Convert from unicode
        $Updates = [System.Text.Encoding]::Unicode.GetString($Updatefeed)
        # Remove header from ini file
        $UpdatesWithoutHeader = $Updates.Split(']')[1]

        $Data = $UpdatesWithoutHeader.Replace("\", "\\")  | ConvertFrom-StringData

        # Build the output object        
        $PSObject = [PSCustomObject] @{
            Version = $Data.Version
            Release = $Release
            URI     = $Data.url
        }
        Write-Output -InputObject $PSObject
            
    }
}
