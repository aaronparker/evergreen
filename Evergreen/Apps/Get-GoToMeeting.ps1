Function Get-GoToMeeting {
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

    # Step through each installer type
    foreach ($item in $res.Get.Download.Uri.GetEnumerator()) {

        # Resolve the URL to the target location
        $URI = Resolve-InvokeWebRequest -Uri $res.Get.Download.Uri[$item.Key]

        # Match version number
        try {
            $Version = [RegEx]::Match($URI, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
        }
        catch {
            $Version = "Unknown"
        }

        # Build the output object; Output object to the pipeline
        $PSObject = [PSCustomObject] @{
            Version = $Version
            Type    = $item.Name
            URI     = $(($URI -split $res.Get.Download.Split)[0])
        }
        Write-Output -InputObject $PSObject
    }
}
