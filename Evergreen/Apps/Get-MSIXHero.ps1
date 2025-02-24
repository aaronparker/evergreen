function Get-MSIXHero {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $UpdateFeed = Invoke-EvergreenRestMethod @params

    # Build the output object
    if ($null -ne $UpdateFeed) {
        $PSObject = [PSCustomObject] @{
            Version = $UpdateFeed.lastVersion
            Date    = ConvertTo-DateTime -DateTime $UpdateFeed.released -Pattern $res.Get.Update.DateFormat
            URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $UpdateFeed.lastVersion
        }
        Write-Output -InputObject $PSObject
    }
}
