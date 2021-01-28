Function Get-MicrosoftWvdRemoteDesktop {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Remote Desktop client for Windows Virtual Desktop.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftWvdRemoteDesktop

            Description:
            Returns the current version and download URL for the Microsoft Remote Desktop client for Windows Virtual Desktop.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    ForEach ($architecture in $res.Get.Download.Uri.Keys) {

        # Grab the download link headers to find the file name
        try {
            #TODO: Update Invoke-WebRequestWrapper to optionally return Headers instead of Content
            $params = @{
                Uri             = $res.Get.Download.Uri[$architecture]
                Method          = "Head"
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            $Headers = (Invoke-WebRequest @params).Headers
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $res.Get.Download.Uri."
            Throw $_
            Break
        }

        If ($Headers) {
            # Match filename
            $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

            # Build the download URL from the headers returned from the API
            # TODO: Update this to better handle changes in the URL structure
            $Url = "$($res.Get.Download.ApiUri)/$($Headers.($res.Get.Download.ApiHeader1))/$($Headers.($res.Get.Download.ApiHeader2))/$($Headers.($res.Get.Download.ApiHeader3))"

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchVersion).Captures.Value
                Architecture = $architecture
                Date         = $Headers['Last-Modified'] | Select-Object -First 1
                Size         = $Headers['Content-Length'] | Select-Object -First 1
                Filename     = $Filename
                URI          = $Url
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a header from $($res.Get.Download.Uri)."
        }
    }
}
