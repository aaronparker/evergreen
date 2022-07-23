Function Get-AdoptiumTemurin11 {
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

    # Pass the repo releases API URL and return a formatted object
    $Releases = Invoke-RestMethodWrapper -Uri $res.Get.Update.Uri
    $Targets = $Releases.binary | Where-Object { $_.os -eq $res.Get.Update.MatchOS `
            -and $_.image_type -match $res.Get.Update.MatchImage }
    ForEach ($Release in $Targets) {
        if ($Null -ne $Release.installer) {
            $PSObject = [PSCustomObject]@{
                Version      = ($Release.scm_ref -split "_")[0]
                Type         = $Release.image_type
                Architecture = Get-Architecture -String $Release.architecture
                Checksum     = $Release.installer.checksum
                Size         = $Release.installer.size
                URI          = $Release.installer.link
            }
            Write-Output -InputObject $PSObject
        }
    }
}
