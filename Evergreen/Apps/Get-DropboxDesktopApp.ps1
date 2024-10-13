function Get-DropboxDesktopApp {
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

    # Get the latest download
    foreach ($Url in $res.Get.Download.Uri) {

        # Resolve the URI from the download URL
        $Response = Resolve-SystemNetWebRequest -Uri $Url

        # Construct the output; Return the custom object to the pipeline
        if ($null -ne $Response) {
            $PSObject = [PSCustomObject] @{
                Version      = [RegEx]::Match($Response.ResponseUri.LocalPath, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                Architecture = Get-Architecture -String $Response.ResponseUri.AbsoluteUri
                Type         = Get-FileType -File $Response.ResponseUri.AbsoluteUri
                Filename     = $(Split-Path -Path $Response.ResponseUri.AbsoluteUri -Leaf) -replace "%20", " "
                URI          = $Response.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
