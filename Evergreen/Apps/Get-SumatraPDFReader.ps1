Function Get-SumatraPDFReader {
    <#
        .SYNOPSIS
            Get the current version and download URL for Sumatra PDF Reader.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-SumatraPDFReader

            Description:
            Returns the current version and download URL for Sumatra PDF Reader.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the SumatraPDFReader version from the text source
    $params = @{
        Uri = $res.Get.Update.Uri
    }
    $Content = Invoke-WebRequestWrapper @params

    If ($Null -ne $Content) {
        try {
            $Version = [RegEx]::Match($Content, $res.Get.Update.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            $Version = "Latest"
        }

        # Construct the output for each architecture
        ForEach ($architecture in $res.Get.Download.Uri.GetEnumerator()) {

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $architecture.Name
                URI          = $res.Get.Download.Uri[$architecture.Key] -replace $res.Get.Download.ReplaceText, $Version
            }
            Write-Output -InputObject $PSObject
        }
    }
    Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to return a usable object from: $($res.Get.Update.Uri)."
    }
}
