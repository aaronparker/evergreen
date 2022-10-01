Function Get-AdobeConnect {
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

    foreach ($Download in $res.Get.Download.Uri.GetEnumerator()) {
        $Object = Resolve-SystemNetWebRequest -Uri $res.Get.Download.Uri[$Download.Key]

        # Build the output object
        if ($null -ne $Object) {

            try {
                Write-Verbose -Message "$($MyInvocation.MyCommand): Uri: $($Object.ResponseUri.AbsoluteUri)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): Match Uri string with regex: $($res.Get.Download.MatchVersion)"
                $Version = [RegEx]::Match($Object.ResponseUri.AbsoluteUri, $res.Get.Download.MatchVersion).Captures.Groups[1].Value
                Write-Verbose -Message "$($MyInvocation.MyCommand): Found version: $Version"
            }
            catch {
                throw $_
            }

            $PSObject = [PSCustomObject] @{
                Version      = $Version -replace "_", "."
                Type         = Get-FileType -File $Object.ResponseUri.AbsoluteUri
                Architecture = if ($Object.ResponseUri.AbsoluteUri -match "32") { "x86" } else { "x64" }
                URI          = $Object.ResponseUri.AbsoluteUri
            }
            Write-Output -InputObject $PSObject
        }
    }
}
