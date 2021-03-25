Function Get-VastLimitsUberAgent {
    <#
            .SYNOPSIS
                Get the current version and download URL for uberAgent.
    
            .NOTES
                Site: https://stealthpuppy.com
                Author: Aaron Parker
                Twitter: @stealthpuppy
            
            .LINK
                https://github.com/aaronparker/Evergreen
    
            .EXAMPLE
                Get-VastLimitsUberAgent
    
                Description:
                Returns the current version and download URLs for uberAgent.
        #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()
    
    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name
    
    # Get latest version and download latest release via API
    $iwcParams = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-WebRequestWrapper @iwcParams
    
    # Construct the output; Return the custom object to the pipeline
    If ($Null -ne $Content) {
        $PSObject = [PSCustomObject] @{
            Version = [RegEx]::Match($Content, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
            URI     = $res.Get.Download.Uri -replace $res.Get.Download.ReplaceText, $Content
        }
        Write-Output -InputObject $PSObject
    }
}
