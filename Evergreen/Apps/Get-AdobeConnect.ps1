function Get-AdobeConnect {
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

    foreach ($Download in $res.Get.Download.Uri.GetEnumerator()) {
        $params = @{
            Uri                = $res.Get.Download.Uri[$Download.Key]
            UserAgent          = $null
            MaximumRedirection = 1
        }
        $Object = Resolve-SystemNetWebRequest @params

        # Build the output object
        if ($null -ne $Object) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Uri: $($Object.ResponseUri.AbsoluteUri)"
            Write-Verbose -Message "$($MyInvocation.MyCommand): Match Uri string with regex: $($res.Get.Download.MatchVersion)"
            $Version = [RegEx]::Match($Object.ResponseUri.AbsoluteUri, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version"

            $PSObject = [PSCustomObject] @{
                Version      = $Version -replace "_", "."
                Type         = Get-FileType -File $Object.ResponseUri.AbsoluteUri
                Architecture = Get-Architecture -String $Download.Key
                URI          = $Object.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
