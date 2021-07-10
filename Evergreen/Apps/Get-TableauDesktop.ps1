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
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Content = Invoke-RestMethodWrapper @params

    If ($Null -ne $Content) {

        # Work out latest version
        $LatestVersion = $Content.versions.version | `
            Sort-Object -Property @{ Expression = { [System.Version]$_.name }; Descending = $true } | `
            Select-Object -First 1

        ForEach ($file in ($LatestVersion.Installer | Where-Object { $_.name -match $res.Get.Update.MatchExtensions })) {

            # Attempt to work out Tableau type based on filename
            try {

                $Type = [RegEx]::Match($file.Name, $res.Get.Update.MatchType).Captures.Groups[1].Value
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
                URI          = $("$($res.Get.Download.Uri)/$($LatestVersion.latestVersionPath)/$($file.Name)")
            }
            Write-Output -InputObject $PSObject
        }
    }
}
