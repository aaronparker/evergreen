function Get-1PasswordCLI {
    <#
        .NOTES
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

    # Get latest version and download latest release via update API
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $updateFeed = Invoke-EvergreenRestMethod @params
    if ($updateFeed.available -eq 1) {

        # Output the object to the pipeline
        foreach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {
            $PSObject = [PSCustomObject] @{
                Version      = $updateFeed.version
                Architecture = $Architecture.Name
                Type         = Get-FileType -File $res.Get.Download.Uri[$Architecture.Name]
                URI          = $res.Get.Download.Uri[$Architecture.Name] -replace $res.Get.Download.ReplaceText, $updateFeed.version
            }
            Write-Output -InputObject $PSObject
        }
    }
    else {
        Write-Warning -Message "$($MyInvocation.MyCommand): failed to find an available from: $($res.Get.Update.Uri)."
    }
}
