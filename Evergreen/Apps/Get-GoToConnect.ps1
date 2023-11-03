Function Get-GoToConnect {
    <#
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

    # Resolve the URL to the target location
    $Update = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    if ($null -ne $Update) {
        $Version = [RegEx]::Match($Update, $res.Get.Update.MatchVersion).Captures.Groups[1].Value

        if ($null -ne $Version) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

            foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {

                # Build the output object; Output object to the pipeline
                $Url = $res.Get.Download.Uri[$Architecture.Key] -replace "#version", $Version
                $PSObject = [PSCustomObject] @{
                    Version      = $Version
                    Architecture = $Architecture.Name
                    Type         = Get-FileType -File $Url
                    URI          = $Url
                }
                Write-Output -InputObject $PSObject
            }
        }
    }
}
