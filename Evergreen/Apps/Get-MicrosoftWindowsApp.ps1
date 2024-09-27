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
        # Grab the download link headers to find the file name
        $params = @{
            Uri          = $Url
            Method       = "Head"
            ReturnObject = "Headers"
        }
        $Headers = Invoke-EvergreenWebRequest @params
        if ($null -ne $Headers) {

            # Match filename
            $Filename = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchFilename).Captures.Groups[1].Value

            # Match version
            $Version = [RegEx]::Match($Headers['Content-Disposition'], $res.Get.Download.MatchVersion).Captures.Value
            if ($Version.Length -eq 0) { $Version = "Unknown" }

            # Construct the output; Return the custom object to the pipeline
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Date         = $Headers['Last-Modified'] | Select-Object -First 1
                Architecture = Get-Architecture -String $Filename
                Filename     = $Filename
                URI          = $Url
            }
            Write-Output -InputObject $PSObject
        }
    }
}
