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
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param(
        [ValidateSet("net45", "net35")]
        [string] $NetVersion = "net45",

        [ValidateSet("x86", "x64")]
        [string] $Architecture = "x64"
    )
    
    $agentURL = "http://www.controlup.com/products/controlup/agent/"
    $pattern = "(\d+\.){3}\d+"
    
    # ControlUP forces TLS 1.2 and rejects TLS 1.1
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $webRequest = Invoke-WebRequest -Uri $agentURL -UseBasicParsing
    $content = $webRequest.Content
    
    #clean up the code into paragraph blocks
    $paragraphSections = $content.Replace("`n", "").Replace("  ", "").Replace("`t", "").Replace("<p>", "#$%^<p>").Split("#$%^").Trim()
    
    #now we are looking for the pattern <p><strong>Current agent version:</strong> 7.2.1.6</p>
    $versionLine = $paragraphSections | Where-Object { $_ -like "*Current*agent*" }
    $splitLines = ($versionLine.Replace('<', '#$%^<').Replace('>', '>#$%^').Split('#$%^')).Trim()
    $version = [Version]::new(($splitLines | Select-String -Pattern $pattern).ToString())
    
    # Write version and download the pipeline
    $PSObject = [PSCustomObject] @{
        Version = $version
        URI     = "https://downloads.controlup.com/agent/$($version.ToString())/ControlUpAgent-$($netversion)-$($architecture).msi"
    }
    Write-Output -InputObject $PSObject
}
