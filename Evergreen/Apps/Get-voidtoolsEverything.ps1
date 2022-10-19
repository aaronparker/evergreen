Function Get-voidtoolsEverything {
    <#
        .SYNOPSIS
            Returns the available voidtools Everything versions.

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

    # Pass the repo releases API URL and return a formatted object
    $Response = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri

    # Build the output object
    If ($Null -ne $Response) {

        # Construct the version number from the response, skipping the first line
        try {
            $Version = ($Response.Split("`n")[1, 2, 3, 4] | ConvertFrom-StringData).Values -join "."
        }
        catch {
            $Version = "Unknown"
        }

        # Return an object for each architecture
        ForEach ($item in $res.Get.Download.Uri.GetEnumerator()) {
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $item.Name
                URI          = $res.Get.Download.Uri[$item.Key]
            }
            Write-Output -InputObject $PSObject
        }
    }
}
