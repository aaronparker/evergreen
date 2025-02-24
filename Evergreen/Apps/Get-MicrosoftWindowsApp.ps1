function Get-MicrosoftWindowsApp {
    <#
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

    foreach ($Url in $res.Get.Download.Uri) {

        # Resolve the Microsoft FwLink URL
        $params = @{
            Uri           = $Url
            WarningAction = "SilentlyContinue"
        }
        $ResolvedUrl = Resolve-MicrosoftFwLink @params

        # Grab the download link headers to find the file name
        $params = @{
            Uri          = $ResolvedUrl.URI
            Method       = "Head"
            ReturnObject = "Headers"
        }
        $Headers = Invoke-EvergreenWebRequest @params
        if ($null -ne $Headers) {

            if ([System.String]::IsNullOrWhiteSpace($Headers['Content-Disposition'])) {
                # Match filename
                $Filename = [RegEx]::Match($ResolvedUrl.URI, $res.Get.Download.MatchFilename).Captures.Groups[1].Value

                # Match version
                $Version = [RegEx]::Match($ResolvedUrl.URI, $res.Get.Download.MatchVersion).Captures.Value
                if ($Version.Length -eq 0) { $Version = "Unknown" }
            }
            else {
                # Match filename
                $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

                # Match version
                $Version = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchVersion).Captures.Value
                if ($Version.Length -eq 0) { $Version = "Unknown" }
            }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                #Date         = $Headers['Last-Modified'] | Select-Object -First 1
                Architecture = Get-Architecture -String $Filename
                Filename     = $Filename
                URI          = $ResolvedUrl.URI
            }
            Write-Output -InputObject $PSObject
        }
    }
}
