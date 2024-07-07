Function Get-AutodeskFusion360 {
    <#
        .SYNOPSIS
            Returns downloads for the latest Autodesk Fusion 360 releases.

        .NOTES
            Author: Patrick S. Seymour
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get latest Fusion 360 version
    $Versions = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    foreach ($installer in $res.Get.Download.Uri.GetEnumerator()) {
        $Url = $res.Get.Download.Uri[$installer.Key]

        if ($Null -ne $Url) {
            # Build object and output to the pipeline
            $PSObject = [PSCustomObject] @{
                Version           = $Versions.'build-version'
                #BuildVersion      = $Versions.'build-version'
                #MajorBuildVersion = $Versions.'major-update-version'
                Type              = Get-FileType -File $Url
                Filename          = (Split-Path -Path $Url -Leaf).Replace('%20', ' ')
                URI               = $Url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
