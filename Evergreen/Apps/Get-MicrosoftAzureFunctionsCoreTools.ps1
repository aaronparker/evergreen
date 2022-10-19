Function Get-MicrosoftAzureFunctionsCoreTools {
    <#
        .SYNOPSIS
            Returns the latest Microsoft Azure Functions Core Tools version number and download.

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
    If ($Null -ne $object) {
        ForEach ($architecture in $res.Get.Download.Uri.GetEnumerator()) {
            $PSObject = [PSCustomObject] @{
                Version      = $object.Version
                Architecture = $architecture.Name
                URI          = $res.Get.Download.Uri[$architecture.Key] -replace $res.Get.Download.ReplaceText, $object.Version
            }
            Write-Output -InputObject $PSObject
        }
    }
}
