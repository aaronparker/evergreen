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

    ForEach ($architecture in $res.Get.Uri.Keys) {

        # Grab the download link headers to find the file name
        try {
            #TODO: turn this into a function
            $params = @{
                Uri             = $res.Get.Uri[$architecture]
                Method          = "Head"
                UseBasicParsing = $True
                ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
            }
            $Headers = (Invoke-WebRequest @params).Headers
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Error at: $res.Get.Uri."
            Throw $_
            Break
        }

        If ($Headers) {
            # Match filename
            $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.MatchFilename).Captures.Groups[1].Value

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.MatchVersion).Captures.Value
                Architecture = $architecture
                Date         = $Headers['Last-Modified'] | Select-Object -First 1
                Size         = $Headers['Content-Length'] | Select-Object -First 1
                Filename     = $Filename
                URI          = $res.Get.Uri[$architecture]
            }
            Write-Output -InputObject $PSObject
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a header from $($res.Get.Uri)."
        }
    }
}
