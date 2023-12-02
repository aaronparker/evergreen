Function Get-OracleJava8 {
    <#
        .SYNOPSIS
            Gets the current available Oracle Java release versions.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Read the update RSS feed
    $UpdateFeed = Invoke-EvergreenRestMethod -Uri $res.Get.Update.Uri

    # Latest version is the last item in the feed
    # Can't cast $_.version to [System.Version] because underscore character is in the string
    $Count = $UpdateFeed.'java-update-map'.mapping.Count
    Write-Verbose -Message "$($MyInvocation.MyCommand): Filter $Count items in feed for latest update."
    $latestUpdate = $UpdateFeed.'java-update-map'.mapping | `
        Where-Object { $_.url -notlike "*-cb.xml" } | `
        Select-Object -Last 1

    # Read the XML listed in the most recent update
    $Feed = Invoke-EvergreenRestMethod -Uri $latestUpdate.url
    if ($null -ne $Feed) {

        # Select the update info
        Write-Verbose -Message "$($MyInvocation.MyCommand): Select item in feed for $($res.Get.Update.Filter)."
        $Update = $Feed.'java-update'.information | Where-Object { $_.lang -eq $res.Get.Update.Filter } | Select-Object -First 1

        # Construct the output; Return the custom object to the pipeline
        foreach ($item in $res.Get.Update.FileStrings.GetEnumerator()) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Build object for $($item.Name)."
            $PSObject = [PSCustomObject] @{
                Version      = $($Update.version | Select-Object -Last 1)
                Architecture = $item.Name
                Type         = Get-FileType -File $($Update.url -replace $res.Get.Update.ReplaceText, $res.Get.Update.FileStrings[$item.Key])
                URI          = $Update.url -replace $res.Get.Update.ReplaceText, $res.Get.Update.FileStrings[$item.Key]
            }
            Write-Output -InputObject $PSObject
        }
    }
}
