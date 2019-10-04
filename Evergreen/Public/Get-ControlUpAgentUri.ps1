Function Get-ControlUpAgentUri {
    <#
        .SYNOPSIS
            Gets the ControlUp latest agent download URI.

        .DESCRIPTION
            Gets the ControlUp latest agent download URI for 64-bit or 32-bit Windows, .NET Framework 3.5 or .NET Framework 4.5.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .PARAMETER NetVersion
            Specify the target .NET Framework version of the agent to return (.NET Framework 3.5 or .NET Framework 4.5)

        .PARAMETER Architecture
            Specify the processor archiecture of Windows for the ControlUp agent

        .EXAMPLE
            Get-ControlUpAgentUri

            Description:
            Returns the latest ControlUp agent with .NET Framework 4.5 support for 64-bit Windows.

        .EXAMPLE
            Get-ControlUpAgentUri -NetVersion net35 -Architecture x86

            Description:
            Returns the latest ControlUp agent with .NET Framework 3.5 support for 32-bit Windows.
#>
    [CmdletBinding()]
    [OutputType([String])]
    Param(
        [ValidateSet("net45","net35")]
        [string] $NetVersion = "net45",

        [ValidateSet("x86","x64")]
        [string] $Architecture = "x64"
    )
    
    # Get version and Agent version and construct the URI
    $version = Get-ControlUpAgentVersion
    $downloadURL = "https://downloads.controlup.com/agent/$($version.ToString())/ControlUpAgent-$($netversion)-$($architecture).msi"
    
    Write-Output $downloadURL
}
