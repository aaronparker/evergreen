Function Get-Gimp {
    <#
        .SYNOPSIS
            Get the current version and download URL for GIMP.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-Gimp

            Description:
            Returns the current version and download URL for GIMP.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    #region Get GIMP details        
    # Query the GIMP update URI to get the JSON
    try {
        $updateFeed = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    }
    catch {
        Throw "Failed to resolve update feed: $($res.Get.Update.Uri)."
        Break
    }
    If ($Null -ne $updateFeed) {

        # Grab latest version
        $Latest = $updateFeed.STABLE[0]
        $MinorVersion = [System.Version] $Latest.version
            
        # Build the download URL
        $Uri = ($res.Get.Download.Uri -replace $res.Get.Download.ReplaceFileName, $Latest.windows.filename) -replace $res.Get.Download.ReplaceVersion, "$($MinorVersion.Major).$($MinorVersion.Minor)"
            
        # Follow the download link which will return a 301/302
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Resolving: $Uri."
            $redirectUrl = Resolve-InvokeWebRequest -Uri $Uri
        }
        catch {
            Throw "Failed to resolve mirror from: $Uri."
            Break  
        }
            
        # Construct the output; Return the custom object to the pipeline
        If ($Null -ne $redirectUrl) {
            $PSObject = [PSCustomObject] @{
                Version = $Latest.version
                Date    = ConvertTo-DateTime -DateTime $Latest.date
                Sha256  = $Latest.windows.sha256
                URI     = $redirectUrl
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a useable URL from $Uri."
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): unable to retrieve content from $($res.Get.Update.Uri)."
    }
    #endregion
}
