Function Get-PDFArranger {
    <#
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Product name is a plural")]
    [CmdletBinding(SupportsShouldProcess = $False)]
    param (
        [Parameter(Mandatory = $False, Position = 0)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject]
        $res = (Get-FunctionResource -AppName ("$($MyInvocation.MyCommand)".Split("-"))[1])
    )

    # Pass the repo releases API URL and return a formatted object
    $params = @{
        Uri          = $res.Get.Uri
        MatchVersion = $res.Get.MatchVersion
        Filter       = $res.Get.MatchFileTypes
    }
    $object = Get-GitHubRepoRelease @params

    # Filter the object to return the latest version with assets
    Write-Verbose -Message "$($MyInvocation.MyCommand): Returned $($object.Count) releases"
    $Latest = $object | Select-Object -First 1
    Write-Verbose -Message "$($MyInvocation.MyCommand): Filter objects for latest version: $($Latest.Version)"
    $object | Where-Object { $Latest.Version -eq $_.Version } | Write-Output
}
