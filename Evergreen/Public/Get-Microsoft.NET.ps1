Function Get-Microsoft.NET {
    <#
        .SYNOPSIS
            Returns the available Microsoft .NET Desktop Runtime versions and download URIs.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftTeams
s
            Description:
            Returns the available Microsoft .NET Desktop Runtime versions and download URIs for Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param ()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Read the version number from the version URI
    ForEach ($Channel in $res.Get.Update.Channels) {
        $Content = Invoke-WebRequestWrapper -Uri ($res.Get.Update.Uri -replace $res.Get.Update.ReplaceText, $Channel)
        If ($Null -ne $Content) {

            # Read last line of the returned content to retrieve the version number
            $Version = (-split $Content)[-1]
            Write-Verbose -Message "$($MyInvocation.MyCommand): found version: $Version."

            # Step through each architecture
            ForEach ($architecture in $res.Get.Download.Architectures) {

                # Build the output object
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Architecture = $architecture
                    Channel      = $Channel
                    URI          = (($res.Get.Download.Uri -replace $res.Get.Download.ReplaceTextVersion, $Version) -replace $res.Get.Download.ReplaceTextArch, $architecture)
                }

                # Output object to the pipeline
                Write-Output -InputObject $PSObject
                $PSObject = $Null
            }
        }
    }
    <#Else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to return content from $($res.Get.Update.Uri)."
    }#>
}