function Get-NagiosCrossPlatformAgent {
    <#
        .NOTES
            Author: Aaron Parker
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri               = $res.Get.Update.Uri
        MatchVersion      = $res.Get.Update.MatchVersion
        Filter            = $res.Get.Update.MatchFileTypes
        ReturnVersionOnly = $true
    }
    $object = Get-GitHubRepoRelease @params

    # Build the output object
    if ($null -ne $object) {
        foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {
            $Uri = $res.Get.Download.Uri[$Architecture.Key] -replace $res.Get.Download.ReplaceText, $object.Version
            $PSObject = [PSCustomObject] @{
                Version      = $object.Version
                Architecture = $Architecture.Name
                Type         = Get-FileType -File $Uri
                URI          = $Uri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
