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

    #region Get XenServer tool details
    $Content = Invoke-WebContent -Uri $script:resourceStrings.Applications.CitrixXenServerTools.Uri -Raw
    $Table = $Content | ConvertFrom-Csv -Delimiter "`t" -Header "Uri", "Version", "Size", "Architecture", "Index"
    ForEach ($row in $Table) {
        $PSObject = [PSCustomObject] @{
            Version      = $row.Version
            Architecture = $row.Architecture
            URI          = $row.Uri
            Size         = $row.Size
        }
        Write-Output -InputObject $PSObject
    }
    #endregion
}
