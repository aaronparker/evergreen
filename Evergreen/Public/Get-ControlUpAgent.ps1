Function Get-ControlUpAgent {
    <#
        .SYNOPSIS
            Gets the ControlUp latest agent version and download URI for 64-bit or 32-bit Windows, .NET Framework 3.5 or .NET Framework 4.5.

        .NOTES
            Author: Bronson Magnan
            Twitter: @cit_bronson

            This functions scrapes the vendor web page to find versions and downloads.
            TODO: find a better method to find version and URLs
        
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

            # Add .NET Framework version properties
            Switch -Regex ($link.href) {
                "net45" { $dotnet = "net45" }
                "net35" { $dotnet = "net35" }
                Default { $dotnet = "Unknown" }
            }

            # Build and array of the latest release and download URLs
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($link.href, $res.Get.MatchVersion).Captures.Value
                Framework    = $dotnet
                Architecture = Get-Architecture -String $link.href
                URI          = $link.href
            }
            Write-Output -InputObject $PSObject
        }
    }
}
