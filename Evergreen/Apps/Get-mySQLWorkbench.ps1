function Get-mySQLWorkbench {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri               = $res.Get.Update.Uri
        MatchVersion      = $res.Get.Update.MatchVersion
        Filter            = $res.Get.Update.MatchFileTypes
        ReturnVersionOnly = $True
    }
    $object = Get-GitHubRepoRelease @params

    # Build the output object
    if ($Null -ne $object) {
        foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {
            $Uri = $res.Get.Download.Uri[$Architecture.Key] -replace $res.Get.Download.ReplaceText, $object.Version
            $PSObject = [PSCustomObject] @{
                Version      = $object.Version
                Type         = Get-FileType -File $Uri
                Architecture = $Architecture.Name
                URI          = $Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
