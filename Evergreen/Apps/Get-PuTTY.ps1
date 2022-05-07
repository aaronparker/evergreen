Function Get-PuTTY {
    <#
        .SYNOPSIS
            Returns the available PuTTY versions.

        .NOTES
            Author: BornToBeRoot
            Twitter: @_BornToBeRoot
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Get latest download url (https://the.earth.li/~sgtatham/putty/latest/ --> https://the.earth.li/~sgtatham/putty/0.xx/)
    $Response = Resolve-SystemNetWebRequest -Uri $res.Get.Update.Uri
    If ($Null -ne $Response) {

        # Extract the version from the redirect url
        $Version = [RegEx]::Match($Response.ResponseUri, $res.Get.Update.MatchVersion).Value
        Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version."

        ForEach ($Architecture in $res.Get.Download.Uri.GetEnumerator()) {

            # Construct the URI
            $Uri = $res.Get.Download.Uri[$Architecture.Key] -replace $res.Get.Download.ReplaceText, $Version

            # Output the Version and URI object
            $PSObject = [PSCustomObject] @{
                Version      = $Version
                Architecture = $Architecture.Name
                Type         = [System.IO.Path]::GetExtension($Uri).TrimStart(".")
                URI          = $Uri
            }
            Write-Output -InputObject $PSObject

        }
    }
}
