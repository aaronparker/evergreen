Function Get-ControlUpAgentVersion {
    <#
        .SYNOPSIS
            Gets the ControlUp latest agent version.

        .DESCRIPTION
            Gets the ControlUp latest available agent version from the ControlUp site.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson
        
        .LINK
            https://github.com/aaronparker/Get.Software

        .EXAMPLE
            Get-ControlUpAgentVersion

            Description:
            Returns the latest ControlUp agent version number.
#>
    [CmdletBinding()]
    [OutputType([Version])]
    Param()
    
    $agentURL = "http://www.controlup.com/products/controlup/agent/"
    $pattern = "(\d+\.){3}\d+"
    
    # ControlUP forces TLS 1.2 and rejects TLS 1.1
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $webRequest = Invoke-WebRequest -Uri $agentURL -UseBasicParsing
    $content = $webRequest.Content
    
    #clean up the code into paragraph blocks
    $paragraphSections = $content.Replace("`n","").Replace("  ","").Replace("`t","").Replace("<p>","#$%^<p>").Split("#$%^").Trim()
    
    #now we are looking for the pattern <p><strong>Current agent version:</strong> 7.2.1.6</p>
    $versionLine = $paragraphSections | Where-Object { $_ -like "*Current*agent*" }
    $splitLines = ($versionLine.Replace('<','#$%^<').Replace('>','>#$%^').Split('#$%^')).Trim()
    $version = [Version]::new(($splitLines | Select-String -Pattern $pattern).ToString())
    
    Write-Output $version
}
