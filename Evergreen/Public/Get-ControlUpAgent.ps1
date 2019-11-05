Function Get-ControlUpAgent {
    <#
        .SYNOPSIS
            Gets the ControlUp latest agent version and download URI.

        .DESCRIPTION
            Gets the ControlUp latest agent version and download URI for 64-bit or 32-bit Windows, .NET Framework 3.5 or .NET Framework 4.5.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-ControlUpAgentUri

            Description:
            Returns the latest ControlUp Agent with .NET Framework 4.5 support for 64-bit Windows.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Query the ControlUp Agent download site
    $iwrParams = @{
        Uri             = $res.Get.Uri
        UseBasicParsing = $True
        ErrorAction     = $script:resourceStrings.Preferences.ErrorAction
    }
    $response = Invoke-WebRequest @iwrParams    
    
    If ($Null -ne $response) {
        $versionLinks = $response.Links -match $res.Get.MatchVersion
    
        ForEach ($link in $versionLinks) {

            # Add .NET Framework version and Architecture properties
            Switch -Regex ($link.href) {
                "x64" { $arch = "x64" }
                "x86" { $arch = "x86" }
                Default { $arch = "Unknown" }
            }
            Switch -Regex ($link.href) {
                "net45" { $dotnet = "net45" }
                "net35" { $dotnet = "net35" }
                Default { $dotnet = "Unknown" }
            }

            # Extract the version number
            # TODO update version regex to return a single group
            $link.href -match $res.Get.MatchVersion | Out-Null
            $version = $matches[0]

            # Build and array of the latest release and download URLs
            $PSObject = [PSCustomObject] @{
                Version      = $version
                Framework    = $dotnet
                Architecture = $arch
                URI          = $link.href
            }
            Write-Output -InputObject $PSObject
        }
    }
}
