function Get-AdoptiumTemurin {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $res
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri         = $res.Get.Update.Uri
        ContentType = $res.Get.Update.ContentType
    }
    $Releases = Invoke-RestMethodWrapper @params

    # Build the output object for each returned release
    foreach ($Release in ($Releases | Where-Object { $_.binary.image_type -match $res.Get.Update.MatchImage })) {
        $PSObject = [PSCustomObject]@{
            Version      = $Release.version.openjdk_version
            ImageType    = $Release.binary.image_type
            Date         = $Release.binary.updated_at
            Checksum     = $Release.binary.installer.checksum
            Size         = $Release.binary.installer.size
            Type         = Get-FileType -File $Release.binary.installer.link
            Architecture = Get-Architecture -String $Release.binary.architecture
            URI          = $Release.binary.installer.link
        }
        Write-Output -InputObject $PSObject
    }
}
