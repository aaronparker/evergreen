Function Get-TableauDesktop {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of Tableau Desktop.

        .NOTES
            Author: Andrew Cooper
            Twitter: @adotcoop
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1]),

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateNotNull()]
        [System.String] $Filter
    )

    # Query the Tableau update API
    $iwcParams = @{
        Uri       = $res.Get.Uri
        UserAgent = $res.Get.UserAgent
    }

    $Content = Invoke-WebRequestWrapper @iwcParams

    If ($Null -ne $Content) {

        # Convert the content to XML to grab the version number
        Try {
            [System.XML.XMLDocument] $xmlDocument = $Content
        }
        Catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): failed to convert feed into an XML object."
        }

        # Work out latest version
        $LatestVersion = $xmlDocument.versions.version | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.name }; Descending = $true } | `
            Select-Object -First 1

        ForEach ($file in ($LatestVersion.Installer | Where-Object { $_.name -match $res.Get.MatchExtensions })) {

            # Attempt to work out Tableau type based on filename
            try {

                $Type = [RegEx]::Match($file.Name, $res.Get.MatchType).Captures.Groups[1].Value
            }
            catch {
                $Type = $file.Name
            }
            
            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $LatestVersion.name
                Type         = $Type
                Architecture = Get-Architecture $file.Name
                Hash         = $file.hash
                HashAlg      = $LatestVersion.hashAlg
                URI          = $("$($res.Get.DownloadUri)/$($LatestVersion.latestVersionPath)/$($file.Name)")
            }
            Write-Output -InputObject $PSObject
        }
    }
}
