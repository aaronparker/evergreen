function Get-PaintDotNet {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Paint.NET tools.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the Paint.NET updates feed
    $Content = Invoke-EvergreenRestMethod -Uri $res.Get.Uri
    if ($null -ne $Content) {

        # Build the output object
        foreach ($Release in $Content.releases) {
            foreach ($File in $Release.files) {
                $PSObject = [PSCustomObject] @{
                    Version      = $Release.version
                    Channel      = $Release.milestone
                    Architecture = $File.architecture
                    URI          = $File.'mirror-urls'[0]
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
