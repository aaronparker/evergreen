function Get-RStudio {
    <#
        .SYNOPSIS
            Returns the available RStudio version and download URI.

        .NOTES
            Author: Jasper Metselaar
            E-mail: jms@du.se
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the Update URI
    $Content = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri
    $array = $Content -split "&"
    $version = $array[2] -replace "update-message=RStudio%20", ""
    $version = $version -replace "%20is%20now.*", ""
    $version = $version -replace "%2B", "-"

    # Step through each installer type
    foreach ($Edition in $res.Get.Download.Edition) {

        # Create download URI
        if ($Edition -eq "Open Source") {
            $DownloadURI = $res.Get.Download.Uri.$Edition + $version + ".exe"
        }
        if ($Edition -eq "Pro") {
            $DownloadURI = $res.Get.Download.Uri.$Edition + $version + ".pro3.exe"
        }

        # Build the output object; Output object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version     = $version
            ProductName = $res.Name
            Edition     = $Edition
            Type        = Get-FileType -File $DownloadURI
            URI         = $DownloadURI
        }
        Write-Output -InputObject $PSObject
    }
}