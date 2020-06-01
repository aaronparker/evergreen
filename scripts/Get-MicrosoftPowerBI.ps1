Function Get-MicrosoftPowerBI {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Power BI desktop client.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
        
        .LINK
            https://github.com/aaronparker/Evergreen

        .EXAMPLE
            Get-MicrosoftPowerBI

            Description:
            Returns the current version and download URL for the Microsoft Power BI desktop client.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param()

    # Get application resource strings from its manifest
    $res = Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]
    Write-Verbose -Message $res.Name

    # Return the update JSON URI
    $updateJson = (Resolve-Uri -Uri $res.Get.Uri).ResponseUri

    # Get the JSON content
    $params = @{
        Uri         = $updateJson
        Raw         = $True
        ContentType = $res.Get.ContentType
    }
    $Content = Invoke-WebContent @params | ConvertFrom-Json
    
    # Construct the output; Return the custom object to the pipeline
    ForEach ($property in $Content.release.PSObject.Properties) {
        Write-Verbose -Message $property.Name
        $PSObject = [PSCustomObject] @{
            Version      = ($Content.release.($property.Name) | Where-Object { $_.Key -eq "ClientUpdateVersion" }).Value
            Architecture = $property.Name
            URI          = ($Content.release.($property.Name) | Where-Object { $_.Key -eq "ClientUpdateLocation" }).Value
        }
        Write-Output -InputObject $PSObject
    }
}
