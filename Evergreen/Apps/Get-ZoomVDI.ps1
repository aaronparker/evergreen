function Get-ZoomVDI {
    <#
        .SYNOPSIS
            Get the current version and download URL for Zoom VDI

        .NOTES
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

    # Step through each URL
    foreach ($Url in $res.Get.Download.Uri) {

        # Resolve the download URL
        $ResolvedUrl = Resolve-SystemNetWebRequest -Uri $Url
        $Uri = ($ResolvedUrl.ResponseUri.AbsoluteUri -split "\?")[0]

        # Create the platform from the file name in the URL
        switch -Regex ($ResolvedUrl.ResponseUri.AbsoluteUri) {
            "Installer" { $Platform = "VDIClient"; break }
            "Citrix" { $Platform = "Citrix"; break }
            "Universal" { $Platform = "Universal"; break }
            default { $Platform = "VDI" }
        }

        # Create an output object
        $Output = [PSCustomObject]@{
            Version      = "Latest"
            Platform     = $Platform
            Installer    = "Admin"
            Size         = $ResolvedUrl.ContentLength
            Type         = Get-FileType -File $Uri
            Architecture = Get-Architecture -String $Uri
            URI          = $Uri
        }
        Write-Output -InputObject $Output
    }
}
