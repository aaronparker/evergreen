Function Get-CitrixXenServerTools {
    <#
        .SYNOPSIS
            Get the current version and download URL for the XenServer tools.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-CitrixXenServerTools

            Description:
            Returns the current version and download URLs for XenServer tools.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Get XenServer tool details
    $Content = Invoke-WebContent -Uri $res.Get.Uri -Raw
    $Table = $Content | ConvertFrom-Csv -Delimiter "`t" -Header "Uri", "Version", "Size", "Architecture", "Index"
    ForEach ($row in $Table) {
        $PSObject = [PSCustomObject] @{
            Version      = $row.Version
            Architecture = $row.Architecture
            Size         = $row.Size
            URI          = $row.Uri
        }
        Write-Output -InputObject $PSObject
    }
    #endregion
}
