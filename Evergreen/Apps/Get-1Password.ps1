Function Get-1Password {
    <#
        .SYNOPSIS
            Get the current version and download URL for 1Password.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-1Password

            Description:
            Returns the current version and download URLs for 1Password.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via update API
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $updateFeed = Invoke-RestMethodWrapper @params
    If ($Null -ne $updateFeed) {

        # Output the object to the pipeline
        ForEach ($item in $updateFeed.($res.Get.Update.Property)) {
            $PSObject = [PSCustomObject] @{
                Version = $item.before
                URI     = $item.url
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
}
