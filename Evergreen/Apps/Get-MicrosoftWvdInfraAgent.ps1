function Get-MicrosoftWvdInfraAgent {
    <#
        .SYNOPSIS
            Get the current version and download URL for the Microsoft Windows Virtual Desktop Infrastructure agent.

        .NOTES
            Site: https://stealthpuppy.com
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    $params = @{
        Uri = $res.Get.Download.Uri
    }
    $Response = Resolve-SystemNetWebRequest @params

    # Match version
    $Version = [RegEx]::Match($Response.ResponseUri.AbsoluteUri, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
    if ($null -ne $Version) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."
    }
    else {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to determine version number from: $($Response.ResponseUri.AbsoluteUri)."
    }

    # Construct the output; Return the custom object to the pipeline
    $PSObject = [PSCustomObject] @{
        Version      = $Version
        Date         = $Response.LastModified.DateTime
        Architecture = Get-Architecture -String $Response.ResponseUri.AbsoluteUri
        URI          = $Response.ResponseUri.AbsoluteUri
    }
    Write-Output -InputObject $PSObject
}
