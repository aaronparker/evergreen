Function Get-BlueJ {
    <#
        .SYNOPSIS
            Get the current version and download URIs for the supported releases of BlueJ.

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
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Query the BlueJ update API
    $iwcParams = @{
        Uri       = $res.Get.Uri
        UserAgent = $res.Get.UserAgent
    }

    $Content = Invoke-EvergreenWebRequest @iwcParams

    If ($Null -ne $Content) {

        # Convert response from UTF8
        Try {
            $Updates = [System.Text.Encoding]::UTF8.GetString($Content)
        }
        Catch {
            Throw "$($MyInvocation.MyCommand): failed to convert feed into to UTF8."
        }

        # Latest version is stored at the top of the file on its own line
        $LatestVersion = $Updates.Split([Environment]::NewLine)[0]

        # Validate that what we obtained above is actually a version in SemVer format
        Try {
            $Version = [RegEx]::Match($LatestVersion, $res.Get.MatchVersion).Captures.Groups[0].Value
        }
        Catch {
            Throw "$($MyInvocation.MyCommand): failed to obtain latest version."
        }

        # Construct the output; Return the custom object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Version
            URI     = $res.Get.DownloadUri -replace $res.Get.ReplaceText, ($Version.Replace(".", ""))
        }
        Write-Output -InputObject $PSObject

    }
}
