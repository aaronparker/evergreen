Function Get-QGIS {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of QGIS.

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

    # Grab the QGIS version file
    $Content = Invoke-WebRequestWrapper $res.Get.Update.Uri

    If ($Null -ne $Content) {

        # Extract the version information from the downloaded file
        try {
            $StringData = [RegEx]::Matches($Content, $res.Get.Update.MatchStringData) 
            $Versions = $StringData | ConvertFrom-StringData
        }
        catch {
            Throw "$($MyInvocation.MyCommand): Failed to extract the version information from downloaded file."
        }

        ForEach ($Edition in $res.Get.Releases.Keys) {

            $Version = $Versions.$($res.Get.Releases[$Edition].Edition).Replace("'", "") 
            $MsiBinary = $Versions.$($res.Get.Releases[$Edition].MSIBinary).Replace("'", "") 

            $DownloadURI = ($res.Get.Download.Uri -replace $res.Get.Download.ReplaceVersion, $Version) -replace $res.Get.Download.ReplaceMsiBinary, $MsiBinary
         
            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version = $Version
                Edition = $Edition
                URI     = $DownloadURI
            }
            Write-Output -InputObject $PSObject
        }
    }
}