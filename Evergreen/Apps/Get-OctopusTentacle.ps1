function Get-OctopusTentacle {
    <#
        .SYNOPSIS
            Get the current version and download URL for Octopus Tentacle

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    foreach ($download in $res.Get.Download.Uri.GetEnumerator()) {

        # Get the latest download
        $Url = Resolve-InvokeWebRequest -Uri $res.Get.Download.Uri[$download.Key]
        if ($null -ne $Url) {

            # Extract the version information from the uri
            try {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found URL: $Url"
                $Version = [RegEx]::Match($Url, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
            }
            catch {
                throw "$($MyInvocation.MyCommand): Failed to extract the version information from the URI."
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $download.Name
                URI          = $Url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
