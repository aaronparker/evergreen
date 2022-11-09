Function Get-AirtameApp {
    <#
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

    # Get the latest download
    foreach ($Installer in $res.Get.Download.Uri.GetEnumerator()) {
        $Url = Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri[$Installer.Key]

        # Construct the output; Return the custom object to the pipeline
        if ($Null -ne $Url) {
            $PSObject = [PSCustomObject] @{
                Version   = [RegEx]::Match($Url.ResponseUri.AbsoluteUri, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                Installer = $Installer.Name
                Type      = Get-FileType -File $Url.ResponseUri.AbsoluteUri
                URI       = $Url.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
