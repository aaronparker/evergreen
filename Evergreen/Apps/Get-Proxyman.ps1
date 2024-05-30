function Get-Proxyman {
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

    # Pass the repo releases API URL and return a formatted object
    # Return the version only because the download is tagged as Linux
    $params = @{
        Uri               = $res.Get.Update.Uri
        MatchVersion      = $res.Get.Update.MatchVersion
        Filter            = $res.Get.Update.MatchFileTypes
        ReturnVersionOnly = $true
    }
    $LatestVersion = Get-GitHubRepoRelease @params

    # Resolve the evergreen download URL
    $Url = Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri

    # Return a formatted object to the pipeline
    [PSCustomObject]@{
        Version      = $LatestVersion.Version
        Date         = $Url.LastModified.ToShortDateString()
        Size         = $Url.ContentLength
        Architecture = Get-Architecture -String $Url.ResponseUri.AbsoluteUri
        Type         = Get-FileType -File $Url.ResponseUri.AbsoluteUri
        URI          = $Url.ResponseUri.AbsoluteUri
    } | Write-Output
}
