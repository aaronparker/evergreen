function Get-MicrosoftFwLink {
    <#
        .SYNOPSIS
            Resolves https://go.microsoft.com/fwlink URLs

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

    process {
        foreach ($Uri in $res.Get.Download.Uri) {

            # Resolve the URL
            $params = @{
                Uri                = $Uri
                MaximumRedirection = $res.Get.Download.MaximumRedirection
            }
            $ResolvedUrl = Resolve-SystemNetWebRequest @params

            try {
                # Find the version number
                $Version = [RegEx]::Match($ResolvedUrl.ResponseUri.AbsoluteUri, "(\d+(\.\d+){1,4}).*").Captures.Groups[1].Value
            }
            catch {
                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to match version number from: $($ResolvedUrl.ResponseUri.AbsoluteUri)."
            }

            # Output a version object
            $Output = [PSCustomObject]@{
                Version      = $Version
                Date         = $ResolvedUrl.LastModified #ConvertTo-DateTime -Date $ResolvedUrl.LastModified -Pattern $res.Get.Download.DatePattern
                Size         = $ResolvedUrl.ContentLength
                Architecture = Get-Architecture -String $ResolvedUrl.ResponseUri.AbsoluteUri
                Type         = Get-FileType -File $ResolvedUrl.ResponseUri.AbsoluteUri
                URI          = $ResolvedUrl.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $Output
        }
    }
}
