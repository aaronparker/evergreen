Function Get-NotepadPlusPlus {
    <#
        .SYNOPSIS
            Returns the latest Notepad++ version and download URI.

        .DESCRIPTION
            Returns the latest Notepad++ version and download URI.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-NotepadPlusPlus

            Description:
            Returns the latest x86 and x64 Notepad++ version and download URI.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Get latest version and download latest release via GitHub API
    $iwcParams = @{
        Uri         = $res.Get.Uri
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @iwcParams

    # Convert the returned release data into a useable object with Version, URI etc.
    $object = ConvertFrom-GitHubReleasesJson -Content $Content -MatchVersion $res.Get.MatchVersion
    Write-Output -InputObject $object
}
